package be.uantwerpen.fti.se.farpooper.model;

import jakarta.persistence.Column;
import jakarta.persistence.Embeddable;

import java.util.Objects;

@Embeddable
public class Pair<X, Y> {

    @Column(name = "latitude")
    private X first;

    @Column(name = "longitude")
    private Y second;

    public Pair() {}
    public Pair(X first, Y second) { this.first = first; this.second = second; }

    public X getFirst() { return first; }
    public void setFirst(X first) { this.first = first; }

    public Y getSecond() { return second; }
    public void setSecond(Y second) { this.second = second; }

    // Si aún tienes First()/Second(), déjalos, pero usa los get*/set* en nuevo código.
}
