package be.uantwerpen.fti.se.farpooper.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import org.hibernate.annotations.CreationTimestamp;

import java.time.LocalDateTime;

@Getter
@Setter
@Entity
@NoArgsConstructor
@AllArgsConstructor
@Table(name = "poops")
public class Poop {

    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    private Long id;


    @Column(name = "skin_id")
    private Long skinId;

    @Column(nullable = false)
    private String name;

    @Column(name = "date_created", nullable = false, updatable = false)
    @CreationTimestamp
    private LocalDateTime dateCreated;

    @Column
    private Integer points;

    @Embedded
    @AttributeOverrides({
            @AttributeOverride(name="first",  column=@Column(name="latitude")),
            @AttributeOverride(name="second", column=@Column(name="longitude"))
    })
    private Pair<Float, Float> coordenates;

    @Column(name = "distance_from_home_cords")
    private Double distanceFromHomeCords;

    public Poop(Long skinId, String name, Integer points, Pair<Float, Float> coordenates, double distanceFromHomeCords) {
        this.skinId = skinId;
        this.name = name;
        this.points = points;
        this.coordenates = coordenates;
        this.dateCreated = LocalDateTime.now();
        this.distanceFromHomeCords = distanceFromHomeCords;
    }
}
