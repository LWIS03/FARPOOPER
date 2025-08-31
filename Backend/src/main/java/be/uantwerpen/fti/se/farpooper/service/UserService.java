package be.uantwerpen.fti.se.farpooper.service;

import be.uantwerpen.fti.se.farpooper.model.Poop;
import be.uantwerpen.fti.se.farpooper.model.User;
import be.uantwerpen.fti.se.farpooper.model.dto.UserEditDto;
import be.uantwerpen.fti.se.farpooper.repositories.UserRepository;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import java.util.Optional;

@Service
public class UserService {

    private final UserRepository userRepository;

    public UserService(UserRepository userRepository) {
        this.userRepository = userRepository;
    }
    public void addUser(UserEditDto user) throws Exception {
        Optional<User> userByEmail = userRepository.findByEmail(user.getEmail());
        if (userByEmail.isPresent()) {
            throw new Exception("EMAIL ALREADY USED");
        }

        Optional<User> userByUsername = userRepository.findByUsername(user.getUsername());
        if (userByUsername.isPresent()) {
            throw new Exception("USERNAME ALREADY IN USE");
        }


        User newUser = new User(user.getUid() ,user.getEmail(), user.getUsername(), user.getHomeCords());
        userRepository.save(newUser);
    }

    public int getUserPoints(String userUid) {
        Optional<User> user = userRepository.findByUid(userUid);
        if (user.isPresent()) {
            return user.get().getPoints();
        }
        return 0;
    }

    public boolean UserExists(String userUid) {
        return userRepository.findByUid(userUid).isPresent();
    }

    public void addPoop(User user, Poop newPoop){
        user.addPoop(newPoop);
        userRepository.save(user);
    }

    public void addPoints(User user, int points) {
        user.addPoints(points);
        userRepository.save(user);
    }

    public Iterable<User> GetAllUsers() {
        return userRepository.findAll();
    }

    public Iterable<User> getFriends(String uid) {
        Optional<User> user = userRepository.findByUid(uid);
        if (user.isPresent()) {
            return user.get().getFriends();
        }
        return null;
    }
    public void addFriend(String uid1, String uid2) {
        Optional<User> user1 = userRepository.findByUid(uid1);
        Optional<User> user2 = userRepository.findByUid(uid2);
        if (user1.isPresent() && user2.isPresent()) {
            user1.get().addFriend(user2.get());
        }
    }

    public void removeFriend(String uid1, String uid2) {
        Optional<User> user1 = userRepository.findByUid(uid1);
        Optional<User> user2 = userRepository.findByUid(uid2);
        if (user1.isPresent() && user2.isPresent()) {
            user1.get().removeFriend(user2.get());
        }
    }

}
