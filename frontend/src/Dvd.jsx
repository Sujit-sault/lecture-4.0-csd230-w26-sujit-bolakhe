import { useState } from 'react';
import { useAuth } from './provider/authProvider';

function Dvd({ id, title, director, genre, releaseYear, rating, price, onDelete, onUpdate, onAddToCart }) {
    const { isAdmin } = useAuth();
    const [isEditing, setIsEditing] = useState(false);
    const [tempTitle, setTempTitle] = useState(title);
    const [tempDirector, setTempDirector] = useState(director);
    const [tempGenre, setTempGenre] = useState(genre);
    const [tempReleaseYear, setTempReleaseYear] = useState(releaseYear);
    const [tempRating, setTempRating] = useState(rating);
    const [tempPrice, setTempPrice] = useState(price);

    const handleSave = () => {
        const updatedDvd = {
            id,
            title: tempTitle,
            director: tempDirector,
            genre: tempGenre,
            releaseYear: parseInt(tempReleaseYear),
            rating: tempRating,
            price: parseFloat(tempPrice),
            copies: 10
        };
        onUpdate(id, updatedDvd);
        setIsEditing(false);
    };

    if (isEditing) {
        return (
            <div className="book-row editing">
                <input type="text" value={tempTitle} onChange={(e) => setTempTitle(e.target.value)} placeholder="Title" />
                <input type="text" value={tempDirector} onChange={(e) => setTempDirector(e.target.value)} placeholder="Director" />
                <input type="text" value={tempGenre} onChange={(e) => setTempGenre(e.target.value)} placeholder="Genre" />
                <input type="number" value={tempReleaseYear} onChange={(e) => setTempReleaseYear(e.target.value)} placeholder="Year" />
                <input type="text" value={tempRating} onChange={(e) => setTempRating(e.target.value)} placeholder="Rating" />
                <input type="number" value={tempPrice} onChange={(e) => setTempPrice(e.target.value)} placeholder="Price" />
                <button onClick={handleSave} className="btn-save">Save</button>
                <button onClick={() => setIsEditing(false)}>Cancel</button>
            </div>
        );
    }

    return (
        <div className="book-row">
            <div className="book-info">
                <h3>{title}</h3>
                <p>
                    <strong>Director:</strong> {director} |{' '}
                    <strong>Genre:</strong> {genre} |{' '}
                    <strong>Year:</strong> {releaseYear} |{' '}
                    <strong>Rating:</strong> {rating} |{' '}
                    <strong>Price:</strong> ${Number(price).toFixed(2)}
                </p>
            </div>
            <div className="book-actions">
                <button onClick={() => onAddToCart(id)} style={{ backgroundColor: '#28a745', color: 'white' }}>🛒 Add to Cart</button>
                {isAdmin && (
                    <>
                        <button onClick={() => setIsEditing(true)} style={{ backgroundColor: '#ffc107' }}>Edit</button>
                        <button onClick={() => onDelete(id)} style={{ backgroundColor: '#ff4444', color: 'white' }}>Delete</button>
                    </>
                )}
            </div>
        </div>
    );
}

export default Dvd;