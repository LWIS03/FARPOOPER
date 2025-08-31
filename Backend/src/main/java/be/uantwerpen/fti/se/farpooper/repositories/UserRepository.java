package be.uantwerpen.fti.se.farpooper.repositories;

import be.uantwerpen.fti.se.farpooper.model.User;
import org.springframework.data.repository.CrudRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface UserRepository extends CrudRepository<User, Long> {
    Optional<User> findByEmail(String email);
    Optional<User> findByUsername(String username);
    Optional<User> findByUid(String uid);
}
