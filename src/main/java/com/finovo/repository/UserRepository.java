package com.finovo.repository;

import com.finovo.entity.UserEntity;
import org.springframework.data.repository.query.Param;
import org.springframework.data.repository.reactive.ReactiveCrudRepository;
import org.springframework.stereotype.Repository;
import reactor.core.publisher.Mono;

@Repository
public interface UserRepository extends ReactiveCrudRepository<UserEntity, Long> {

    Mono<UserEntity> findByEmailAndPassword(@Param("email") String email,
                                            @Param("password") String password);
}

