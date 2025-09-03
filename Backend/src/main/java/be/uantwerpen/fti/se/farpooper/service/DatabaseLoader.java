package be.uantwerpen.fti.se.farpooper.service;
import be.uantwerpen.fti.se.farpooper.model.User;
import be.uantwerpen.fti.se.farpooper.repositories.UserRepository;
import jakarta.annotation.PostConstruct;
import org.springframework.context.annotation.Profile;
import org.springframework.stereotype.Component;

@Component
@Profile("dev") /
public class DatabaseLoader {

    private final UserRepository userRepository;

    public DatabaseLoader(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    @PostConstruct
    public void initDatabase() {

      //  User user = new User("1234", "test@example.com", "testuser");
        //userRepository.save(user);

        //System.out.println("Datos de prueba cargados:");
        //System.out.println("User ID = " + user.getId());
    }
}