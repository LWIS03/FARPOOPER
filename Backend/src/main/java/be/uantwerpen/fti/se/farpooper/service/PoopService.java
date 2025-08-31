package be.uantwerpen.fti.se.farpooper.service;

import be.uantwerpen.fti.se.farpooper.model.Pair;
import be.uantwerpen.fti.se.farpooper.model.Poop;
import be.uantwerpen.fti.se.farpooper.model.User;
import be.uantwerpen.fti.se.farpooper.model.dto.PoopDto;
import be.uantwerpen.fti.se.farpooper.repositories.PoopRepository;
import be.uantwerpen.fti.se.farpooper.repositories.UserRepository;
import jakarta.persistence.criteria.CriteriaBuilder;
import org.springframework.stereotype.Service;

import java.util.Optional;

@Service
public class PoopService {
    //////////////// * DEFAULT VALUES * ///////////////
    private final double EARTH_RADIUS = 6371; // IN KM //
    private final long DEFAULT_SKIN = 1;
    ///////////////////////////////////////////////////

    private final PoopRepository popoopRepository;
    private final UserRepository userRepository;
    private final PoopRepository poopRepository;
    private final UserService userService;

    public PoopService(PoopRepository popoopRepository, UserRepository userRepository, PoopRepository poopRepository, UserService userService) {
        this.popoopRepository = popoopRepository;
        this.userRepository = userRepository;
        this.poopRepository = poopRepository;
        this.userService = userService;
    }

    public Iterable<Poop> GetAllPoops() {
        return popoopRepository.findAll();
    }

    public Iterable<Poop> getUserPoops(String uid){
        Optional<User> user = userRepository.findByUid(uid);
        return user.get().getPoops();
    }
    public int addPoop(PoopDto poopDto){
        Pair<Float, Float> poopCoords = poopDto.getCoordinates();

        if(poopCoords.getFirst() >= -90 && poopCoords.getFirst() <= 90) {
            if(poopCoords.getFirst() >= -180 && poopCoords.getSecond() <= 180){

                Optional<User> user = userRepository.findByUid(poopDto.getUid());
                if(user.isPresent()) {
                    System.out.println(user.get().getUsername());
                    Pair<Float, Float> homeCoords = user.get().getHomeCords();
                    double Distance = CalculateDistanceHaversine(poopCoords, homeCoords);

                    // WE START MAKING THE NEW POOP // LET HIM COOK!!!
                    double DistanceMeters = Distance * 1000;
                    int Points = CalculatePoints(DistanceMeters);

                    Poop newPoop = new Poop(DEFAULT_SKIN, poopDto.getName(), Points, poopCoords, DistanceMeters);

                    // THE POOP IS COOKED //
                    poopRepository.save(newPoop);
                    userService.addPoop(user.get(), newPoop);
                    userService.addPoints(user.get(), newPoop.getPoints());
                    return Points;
                }
                return 0;
            }
            return 0;
        }
        return 0;

    }

    ////// HERE WE CALCULATE THE POINTS //////////
    ////// EVERY 100 METERS 10 POINTS ///////////
    private int CalculatePoints(double Distance){
        // Distance en METROS
        if (Distance <= 0) return 1; // 0 m -> 1 puntos
        int buckets = (int) Math.ceil(Distance / 100.0);
        return Math.max(10, buckets * 10); // mínimo 10 si hay distancia > 0
    }

    private boolean ItsZeroAndItHasDecimals(double number) {
        return (number != 0 && Math.floor(Math.abs(number)) == 0);
    }
    ////////////////////// END /////////////////////////////////


    /////////////////////////////////////////////////////////
    // * HERE WE CALCULATE THE DISTANCE BETWEEN 2 POINTS * //
    /////////////////////////////////////////////////////////
    //               I USE HAVERSINE                       //
    /////////////////////////////////////////////////////////
    private double CalculateDistanceHaversine(Pair<Float, Float> poopCoords, Pair<Float, Float> homeCoords) {
        double latPoopRad = toRadians(poopCoords.getFirst());
        double latHomeRad = toRadians(homeCoords.getFirst());

        double lonPoopRad = toRadians(poopCoords.getSecond());
        double lonHomeRad = toRadians(homeCoords.getSecond());

        double haversineCore = CalculateHaversineCore(latPoopRad, latHomeRad, lonPoopRad, lonHomeRad);
        double angularDistance = CalculateAngularDistance(haversineCore);

        return EARTH_RADIUS * angularDistance;
    }

    private Double CalculateAngularDistance(double HaversineCore) {
        double root = Math.sqrt(HaversineCore);
        double root2 = Math.sqrt(1- HaversineCore);

        return 2 * Math.atan2(root, root2);
    }

    private double CalculateHaversineCore(double latPoopRad, double latHomeRad, double lonPoopRad, double lonHomeRad) {
        double latDiff = latPoopRad - latHomeRad;
        double lonDiff = lonPoopRad - lonHomeRad;

        double sinLat = Math.pow(Math.sin(latDiff / 2), 2);
        double sinLon = Math.pow(Math.sin(lonDiff / 2), 2);

        double cosPoopLat = Math.cos(latPoopRad);
        double cosHomeLat = Math.cos(latHomeRad);

        return sinLat + (cosPoopLat * cosHomeLat * sinLon);
    }

    private double toRadians(float degrees) {
        return  degrees * (Math.PI/180);
    }
    ////////////////////// *** END *** //////////////////////
}
