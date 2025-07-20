package com.finovo.controller;

import com.finovo.service.ChatService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.*;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

@RestController
@RequiredArgsConstructor
public class ChatController {
    private final ChatService chatService;

    @GetMapping("/chat/{message}")
    public Mono<String> chat(@PathVariable("message") String message) {
        return Mono.just(chatService.chat(message));
    }

    @GetMapping(value="/chat/stream/{message}", produces = MediaType.TEXT_EVENT_STREAM_VALUE)
    public Flux<String> chatStreaming(@PathVariable("message") String message) {
        return chatService.streamChat(message);
    }
}
