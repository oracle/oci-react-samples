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

package com.oracle.dev.jdbc.services;

import java.util.Iterator;
import java.util.List;
import java.util.Map;

import org.springframework.ai.chat.ChatResponse;
import org.springframework.ai.chat.prompt.Prompt;
import org.springframework.ai.chat.prompt.PromptTemplate;
import org.springframework.ai.document.Document;
import org.springframework.ai.ollama.OllamaChatClient;
import org.springframework.ai.vectorstore.SearchRequest;
import org.springframework.ai.vectorstore.VectorStore;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class OracleDatabaseVectorService {

  @Autowired
  private VectorStore vectorStore;

  private final OllamaChatClient aiClient;

  OracleDatabaseVectorService(OllamaChatClient aiClient) {
    this.aiClient = aiClient;
  }

  public VectorStore getVectorStore() {
    return vectorStore;
  }

  public String rag(String question) {
    String START = "\n<article>\n";
    String STOP = "\n</article>\n";
    List<Document> similarDocuments = this.vectorStore
        .similaritySearch(SearchRequest.query(question).withTopK(4));
    Iterator<Document> iterator = similarDocuments.iterator();
    StringBuilder context = new StringBuilder();
    while (iterator.hasNext()) {
      Document document = iterator.next();
      context.append(document.getId() + ".");
      context.append(START + document.getFormattedContent() + STOP);
    }
    PromptTemplate promptTemplate = new PromptTemplate(templateBasic);
    Prompt prompt = promptTemplate
        .create(Map.of("documents", context, "question", question));
    ChatResponse aiResponse = aiClient.call(prompt);
    return aiResponse.getResult().getOutput().getContent();
  }

  public List<Document> getSimilarDocs(String message) {
    List<Document> similarDocuments = this.vectorStore
        .similaritySearch(message);
    return similarDocuments;
  }

  private final String templateBasic = """
      DOCUMENTS:
      {documents}

      QUESTION:
      {question}

      INSTRUCTIONS:
      Answer the questions using the DOCUMENTS above.
      If the DOCUMENTS do not have the information to answer the QUESTION, return:
      I do not have enough information to answer this question.
      """;
}
