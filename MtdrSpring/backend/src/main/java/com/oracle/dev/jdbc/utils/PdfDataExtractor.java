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

package com.oracle.dev.jdbc.utils;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.ai.reader.ExtractedTextFormatter;
import org.springframework.ai.reader.pdf.PagePdfDocumentReader;
import org.springframework.ai.reader.pdf.config.PdfDocumentReaderConfig;
import org.springframework.ai.transformer.splitter.TokenTextSplitter;
import org.springframework.ai.vectorstore.VectorStore;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.Resource;
import org.springframework.jdbc.core.simple.JdbcClient;
import org.springframework.stereotype.Component;

import com.oracle.dev.jdbc.vectorstore.OracleDatabaseVectorStore;

import jakarta.annotation.PostConstruct;

@Component
public class PdfDataExtractor {

  private static final Logger log = LoggerFactory
      .getLogger(PdfDataExtractor.class);

  final JdbcClient jdbcClient;
  final VectorStore vectorStore;

  @Value("classpath:/pdf/Whats-in-OracleDB23ai-for-Java-Developers.pdf")
  private Resource pdfResource;

  PdfDataExtractor(JdbcClient jdbcClient, VectorStore vectorStore) {
    this.jdbcClient = jdbcClient;
    this.vectorStore = vectorStore;
  }

  @PostConstruct
  public void init() {
    Integer count = jdbcClient
        .sql("select count(*) from " + OracleDatabaseVectorStore.TABLE_NAME)
        .query(Integer.class).single();

    log.info("Total Rows: {}", count);

    if (count == 0) {

      log.info("Ingesting PDF into Vector Store");
      var config = PdfDocumentReaderConfig.builder()
          .withPageExtractedTextFormatter(new ExtractedTextFormatter.Builder()
              .withNumberOfBottomTextLinesToDelete(0)
              .withNumberOfTopPagesToSkipBeforeDelete(0).build())
          .withPagesPerDocument(1).build();

      var pdfReader = new PagePdfDocumentReader(pdfResource, config);
      var textSplitter = new TokenTextSplitter();
      vectorStore.accept(textSplitter.apply(pdfReader.get()));

      log.info("Application is ready");
    }
  }
}
