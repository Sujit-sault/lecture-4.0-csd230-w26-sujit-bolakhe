package csd230.bookstore.repositories;

import csd230.bookstore.entities.DvdEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface DvdEntityRepository extends JpaRepository<DvdEntity, Long> {
}