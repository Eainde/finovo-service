package com.finovo.config;

import dev.langchain4j.model.chat.ChatLanguageModel;
import dev.langchain4j.model.chat.StreamingChatLanguageModel;
import dev.langchain4j.model.embedding.EmbeddingModel;
import dev.langchain4j.model.vertexai.VertexAiEmbeddingModel;
import dev.langchain4j.model.vertexai.VertexAiGeminiChatModel;
import dev.langchain4j.model.vertexai.VertexAiGeminiStreamingChatModel;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class VertexAiConfig {
    private static final String PROJECT_ID = "finovo-466315";
    private static final String LOCATION = "europe-west2";
    private static final String ENDPOINT = "europe-west2-aiplatform.googleapis.com:443";
    private static final String EMBEDDING_MODEL_NAME = "textembedding-gecko@003";
    private static final String CHAT_MODEL_NAME = "gemini-1.5-pro-002";
    private static final String PUBLISHER = "google";

    @Bean
    public EmbeddingModel embeddingModel(){
        return VertexAiEmbeddingModel.builder()
                .endpoint(ENDPOINT)
                .project(PROJECT_ID)
                .location(LOCATION)
                .publisher(PUBLISHER)
                .modelName(EMBEDDING_MODEL_NAME)
                .maxRetries(3)
                .build();
    }

    @Bean
    public ChatLanguageModel chatModel() {
        return VertexAiGeminiChatModel.builder()
                .project(PROJECT_ID)
                .location(LOCATION)
                .modelName(CHAT_MODEL_NAME)
                .maxOutputTokens(1000)
                .build();
    }

    @Bean
    public StreamingChatLanguageModel streamingChatModel() {
        return VertexAiGeminiStreamingChatModel.builder()
                .project(PROJECT_ID)
                .location(LOCATION)
                .modelName(CHAT_MODEL_NAME)
                .build();
    }

}
