package com.finovo.service;

import com.finovo.domain.Chat;
import dev.langchain4j.data.message.AiMessage;
import dev.langchain4j.model.StreamingResponseHandler;
import dev.langchain4j.model.chat.ChatLanguageModel;

import dev.langchain4j.model.chat.StreamingChatLanguageModel;
import dev.langchain4j.model.output.Response;
import dev.langchain4j.service.AiServices;
import lombok.AllArgsConstructor;
import lombok.NoArgsConstructor;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.web.bind.annotation.RequestBody;
import reactor.core.publisher.Flux;
import reactor.core.publisher.FluxSink;

@Service
@RequiredArgsConstructor
public class ChatService {
    private final ChatLanguageModel chatLanguageModel;
    private final StreamingChatLanguageModel streamingChatModel;


    public String chat(String userMessage) {
        Chat chat = AiServices.builder(Chat.class).chatLanguageModel(chatLanguageModel).build();
        return chat.chat(userMessage);
    }

    public Flux<String> streamChat(String prompt) {
        return Flux.create(emitter -> {
            streamingChatModel.generate(
                    prompt,
                    new StreamingResponseHandler<AiMessage>() {
                        @Override
                        public void onNext(String token) { emitter.next(token); }
                        @Override
                        public void onComplete(Response<AiMessage> r) { emitter.complete(); }
                        @Override
                        public void onError(Throwable t)  { emitter.error(t); }
                    }
            );
        }, FluxSink.OverflowStrategy.BUFFER);
    }
}
