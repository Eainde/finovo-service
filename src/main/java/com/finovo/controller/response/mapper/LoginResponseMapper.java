package com.finovo.controller.response.mapper;

import com.finovo.controller.response.LoginResponse;
import com.finovo.entity.UserEntity;

public class LoginResponseMapper {
    public static LoginResponse mapToLoginResponse(UserEntity userEntity) {
        return LoginResponse.builder()
                .id(userEntity.getId())
                .username(userEntity.getUsername())
                .email(userEntity.getEmail())
                .password(userEntity.getPassword())
                .age(userEntity.getAge())
                .role(userEntity.getRole())
                .salary(userEntity.getSalary())
                .goal(userEntity.getGoal())
                .build();
    }
}
