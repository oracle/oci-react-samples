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

package com.oracle.dev.jdbc.controllers;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.ai.document.Document;
import org.springframework.ai.embedding.EmbeddingResponse;
import org.springframework.ai.ollama.OllamaChatClient;
import org.springframework.ai.ollama.OllamaEmbeddingClient;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestParam;

import com.oracle.dev.jdbc.services.OracleDatabaseVectorService;
import com.oracle.dev.jdbc.utils.Payload;

@Controller
public class OracleDatabaseController {

  private final OllamaEmbeddingClient embeddingClient;
  private final OracleDatabaseVectorService vectorService;
  private static final Logger logger = LoggerFactory
      .getLogger(OracleDatabaseController.class);

  @Autowired
  public OracleDatabaseController(OllamaEmbeddingClient embeddingClient,
      OllamaChatClient chatClient, OracleDatabaseVectorService vectorService) {
    this.embeddingClient = embeddingClient;
    this.vectorService = vectorService;
    logger.info("Controller started.");
  }

  @GetMapping("/ragpage")
  public String ragForm(Model model) {
    return "rag";
  }

  @PostMapping("/rag23aivectorstore")
  public String rag(@RequestParam(value = "query") String query, Model model) {
    String answer = this.vectorService.rag(query);
    logger.info(answer);
    model.addAttribute("answer", answer);
    return "result";
  }

  @PostMapping("/search-similar")
  public List<Map<String, Object>> search(@RequestBody Payload message) {
    List<Map<String, Object>> resultList = new ArrayList<>();
    List<Document> similarDocs = this.vectorService
        .getSimilarDocs(message.getMessage());
    for (Document d : similarDocs) {
      Map<String, Object> metadata = d.getMetadata();
      // TODO - test this Map refactoring
      Map<String, Object> doc = new HashMap<>();
      doc.put("id", d.getId());
      doc.put("text", d.getContent());
      doc.put("metadata", metadata);
      resultList.add(doc);
    }
    return resultList;
  }

  //TODO - transfer to service OracleDatabaseVectorService
  @GetMapping("/embedding")
  public Map embed(
      @RequestParam(value = "message", defaultValue = "Give me a trading strategy") String message) {
    EmbeddingResponse embeddingResponse = this.embeddingClient
        .embedForResponse(List.of(message));
    return Map.of("embedding", embeddingResponse);
  }

//TODO - transfer to service OracleDatabaseVectorService
  @PostMapping("/embedding")
  public Map<String, Object> embed(@RequestBody Payload message) {
    EmbeddingResponse embeddingResponse = this.embeddingClient
        .embedForResponse(List.of(message.getMessage()));
    return Map.of("embedding", embeddingResponse);
  }

}