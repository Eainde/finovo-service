package com.finovo.service;

import com.finovo.entity.UserEntity;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import reactor.core.publisher.Mono;
import com.finovo.repository.UserRepository;

@Service
@RequiredArgsConstructor
public class LoginService {
    private final UserRepository userRepository;

    public Mono<UserEntity> login(String email, String password) {
        return userRepository.findByEmailAndPassword(email, password);
    }
}
