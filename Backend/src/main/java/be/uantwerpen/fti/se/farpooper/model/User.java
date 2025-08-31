package be.uantwerpen.fti.se.farpooper.model;

import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.LocalDateTime;
import java.util.HashSet;
import java.util.Set;

@Getter
@Setter
@Entity
@NoArgsConstructor
@Table(name = "Users")
public class User {

    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    private Long id;

    @Column(name = "firebase_idetifier", unique = true)
    private String uid;

    @Column(nullable = false, unique = true)
    private String email;

    @Column(unique = true)
    private String username;

    @Embedded
    @AttributeOverrides({
            @AttributeOverride(name = "first",  column = @Column(name = "latitude")),
            @AttributeOverride(name = "second", column = @Column(name = "longitude"))
    })
    private Pair<Float, Float> HomeCords = new Pair<>();

    @OneToMany(fetch = FetchType.EAGER, cascade = CascadeType.ALL)
    @JoinTable(
            name = "user_poops",
            joinColumns = {@JoinColumn(name = "user_id", referencedColumnName = "id", nullable = false)},
            inverseJoinColumns = {@JoinColumn(name = "poop_id", referencedColumnName = "id", nullable = false)}
    )
    Set<Poop> poops = new HashSet<>();

    @ManyToMany
    @JoinTable(
            name = "user_friends",
            joinColumns = @JoinColumn(name = "user_id", referencedColumnName = "id"),
            inverseJoinColumns = @JoinColumn(name = "friend_id", referencedColumnName = "id")
    )
    @JsonIgnore
    Set<User> friends = new HashSet<>();

    @Column
    private Integer points;

    @Column(name = "date_created", nullable = false, updatable = false)
    @CreationTimestamp
    private LocalDateTime dateCreated;

    @Column(name = "updated_on")
    @UpdateTimestamp
    private LocalDateTime updateDateTime;

    public User(String uid, String email, String username, Pair<Float, Float> homeCords) {
        this.uid = uid;
        this.email = email;
        this.username = username;
        this.points = 0;
        this.dateCreated = LocalDateTime.now();
        this.updateDateTime = LocalDateTime.now();
        this.HomeCords = homeCords;
    }
    public void addPoop(Poop poop){
        poops.add(poop);
    }

    public void addPoints(Integer points){
        this.points += points;
    }

    public boolean addFriend(User user){
        if(user == null || user.equals(this)) return false;
        else if(friends.contains(user)) return false;
        this.friends.add(user);
        user.getFriends().add(this);
        return true;
    }

    public boolean removeFriend(User user){
        if(user == null || user.equals(this)) return false;
        if(!friends.contains(user)) return false;
        this.friends.remove(user);
        user.getFriends().remove(this);
        return true;
    }



}
