package be.uantwerpen.fti.se.farpooper.repositories;

import be.uantwerpen.fti.se.farpooper.model.Poop;
import org.springframework.data.repository.CrudRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface PoopRepository extends CrudRepository<Poop, Long> {
}
