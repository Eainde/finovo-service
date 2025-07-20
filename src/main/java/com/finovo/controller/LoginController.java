package com.finovo.controller;

import com.finovo.controller.request.LoginRequest;
import com.finovo.controller.response.LoginResponse;
import com.finovo.entity.UserEntity;
import com.finovo.service.LoginService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;
import reactor.core.publisher.Mono;

@RestController
@CrossOrigin(origins = "*")
@RequiredArgsConstructor
public class LoginController {
  private final LoginService loginService;

  @PostMapping("/login")
  public Mono<UserEntity> login(@RequestBody LoginRequest loginRequest) {
    return loginService.login(loginRequest.getEmail(), loginRequest.getPassword());
  }
}
