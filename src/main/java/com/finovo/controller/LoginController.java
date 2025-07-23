package com.finovo.controller;

import com.finovo.controller.request.LoginRequest;
import com.finovo.controller.response.LoginResponse;
import com.finovo.controller.response.mapper.LoginResponseMapper;
import com.finovo.entity.UserEntity;
import com.finovo.service.LoginService;
import lombok.NoArgsConstructor;
import lombok.RequiredArgsConstructor;
import org.modelmapper.ModelMapper;
import org.springframework.web.bind.annotation.*;
import reactor.core.publisher.Mono;

@RestController
@RequiredArgsConstructor
public class LoginController {
  private final LoginService loginService;

  @PostMapping("/login")
  public Mono<LoginResponse> login(@RequestBody LoginRequest loginRequest) {
    return loginService.login(loginRequest.getEmail(), loginRequest.getPassword())
            .map(LoginResponseMapper::mapToLoginResponse)
            .switchIfEmpty(Mono.error(new RuntimeException("Invalid login credentials")));
  }
}
