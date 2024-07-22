/*
  Copyright (c) 2024, Oracle and/or its affiliates.

  This software is dual-licensed to you under the Universal Permissive License
  (UPL) 1.0 as shown at https://oss.oracle.com/licenses/upl or Apache License
  2.0 as shown at http://www.apache.org/licenses/LICENSE-2.0. You may choose
  either license.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

     https://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
*/

package com.oracle.dev.jdbc.vectorstore;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.stream.Collectors;
import java.util.stream.IntStream;

import org.springframework.ai.document.Document;
import org.springframework.ai.embedding.EmbeddingClient;
import org.springframework.ai.vectorstore.SearchRequest;
import org.springframework.ai.vectorstore.VectorStore;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.PreparedStatementSetter;
import org.springframework.jdbc.core.RowMapper;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.oracle.dev.jdbc.utils.OracleDistanceType;

import oracle.jdbc.OracleType;
import oracle.sql.VECTOR;

public class OracleDatabaseVectorStore implements VectorStore {

  public static final String TABLE_NAME = "VECTOR_STORE";

  private final JdbcTemplate jdbcTemplate;

  private final EmbeddingClient embeddingClient;

  private OracleDistanceType distanceType;

  private ObjectMapper objectMapper = new ObjectMapper();

  private static class DocumentRowMapper implements RowMapper<Document> {

    private static final String COLUMN_EMBEDDING = "vector_data";

    private static final String COLUMN_METADATA = "metadata";

    private static final String COLUMN_ID = "id";

    private static final String COLUMN_CONTENT = "content";

    private ObjectMapper objectMapper;

    public DocumentRowMapper(ObjectMapper objectMapper) {
      this.objectMapper = objectMapper;
    }

    @Override
    public Document mapRow(ResultSet rs, int rowNum) throws SQLException {
      String id = rs.getString(COLUMN_ID);
      String content = rs.getString(COLUMN_CONTENT);
      String metadata = rs.getString(COLUMN_METADATA);
      var embedding = rs.getObject(COLUMN_EMBEDDING, VECTOR.class);
      var document = new Document(id, content, toMap(metadata));
      document.setEmbedding(toDoubleList(embedding));
      return document;
    }

    private List<Double> toDoubleList(VECTOR embedding) throws SQLException {
      float[] floatArray = VECTOR.toFloatArray(embedding.getBytes());
      List<Double> doubleEmbedding = IntStream.range(0, floatArray.length)
          .mapToDouble(i -> floatArray[i]).boxed().collect(Collectors.toList());
      return doubleEmbedding;
    }

    @SuppressWarnings("unchecked")
    private Map<String, Object> toMap(String metadata) {
      try {
        return (Map<String, Object>) objectMapper.readValue(metadata,
            Map.class);
      } catch (JsonProcessingException e) {
        throw new RuntimeException(e);
      }
    }
  }

  public OracleDatabaseVectorStore(JdbcTemplate jdbcTemplate,
      EmbeddingClient embeddingClient, OracleDistanceType distanceType) {
    this.jdbcTemplate = jdbcTemplate;
    this.embeddingClient = embeddingClient;
    this.distanceType = distanceType;
  }

  @Override
  public void add(List<Document> documents) {
    for (Document document : documents) {
      var embedding = this.embeddingClient.embed(document);
      document.setEmbedding(embedding);
      String id = document.getId();
      String content = document.getContent();
      var metadata = document.getMetadata();
      float[] oEmbedding = toFloatArray(embedding);

      jdbcTemplate.update(
          """
              MERGE INTO VECTOR_STORE t USING (SELECT ? AS ID, ? AS CONTENT, ? AS METADATA, ? AS VECTOR_DATA FROM DUAL) s ON (t.ID = s.ID)
              WHEN MATCHED THEN UPDATE SET t.VECTOR_DATA = s.VECTOR_DATA
              WHEN NOT MATCHED THEN INSERT (id, CONTENT, METADATA, VECTOR_DATA) VALUES (s.ID, s.CONTENT, s.METADATA, s.VECTOR_DATA)
              """,
          new PreparedStatementSetter() {
            @Override
            public void setValues(PreparedStatement ps) throws SQLException {
              ps.setString(1, id);
              ps.setString(2, content);
              try {
                ps.setString(3, objectMapper.writeValueAsString(metadata));
              } catch (JsonProcessingException e) {
                e.printStackTrace();
              } catch (SQLException e) {
                e.printStackTrace();
              }
              ps.setObject(4, oEmbedding, OracleType.VECTOR);
            }
          });
    }
  }

  @Override
  public Optional<Boolean> delete(List<String> idList) {
    int updateCount = 0;
    for (String id : idList) {
      int count = jdbcTemplate
          .update("DELETE FROM " + TABLE_NAME + " WHERE id = ?", id);
      updateCount = updateCount + count;
    }
    return Optional.of(updateCount == idList.size());
  }

  @Override
  public List<Document> similaritySearch(SearchRequest request) {
    VECTOR queryEmbedding = null;
    try {
      queryEmbedding = VECTOR
          .ofFloat64Values(getVectorEmbedding(request.getQuery()));
    } catch (SQLException e) {
      e.printStackTrace();
    }
    return this.jdbcTemplate.query(
        "SELECT * FROM " + TABLE_NAME
            + " ORDER BY VECTOR_DISTANCE(VECTOR_DATA, ?, " + distanceType.name()
            + ") FETCH FIRST " + request.getTopK() + " ROWS ONLY",
        new DocumentRowMapper(this.objectMapper), queryEmbedding);
  }

  private float[] toFloatArray(List<Double> embeddingDouble) {
    float[] embeddingFloat = new float[embeddingDouble.size()];
    int i = 0;
    for (Double d : embeddingDouble) {
      embeddingFloat[i++] = d.floatValue();
    }
    return embeddingFloat;
  }

  private float[] getVectorEmbedding(String query) {
    List<Double> embedding = this.embeddingClient.embed(query);
    return toFloatArray(embedding);
  }

}
