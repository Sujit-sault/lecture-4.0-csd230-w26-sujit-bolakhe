import { useState } from 'react';

function DvdForm({ onDvdAdded, api }) {
    const [title, setTitle] = useState('');
    const [director, setDirector] = useState('');
    const [genre, setGenre] = useState('');
    const [releaseYear, setReleaseYear] = useState(2024);
    const [rating, setRating] = useState('PG-13');
    const [price, setPrice] = useState(0);

    const handleSubmit = async (e) => {
        e.preventDefault();
        try {
            const res = await api.post('/dvds', {
                title, director, genre,
                releaseYear: parseInt(releaseYear),
                rating,
                price: parseFloat(price),
                copies: 10
            });
            alert("DVD Saved!");
            onDvdAdded(res.data);
            setTitle(''); setDirector(''); setGenre('');
            setReleaseYear(2024); setRating('PG-13'); setPrice(0);
        } catch (err) {
            alert("Save failed.");
        }
    };

    return (
        <form onSubmit={handleSubmit} className="form-style">
            <h3>Add New DVD</h3>
            <input type="text" placeholder="Title" value={title} onChange={(e) => setTitle(e.target.value)} required />
            <input type="text" placeholder="Director" value={director} onChange={(e) => setDirector(e.target.value)} required />
            <input type="text" placeholder="Genre" value={genre} onChange={(e) => setGenre(e.target.value)} required />
            <input type="number" placeholder="Release Year" value={releaseYear} onChange={(e) => setReleaseYear(e.target.value)} required />
            <select value={rating} onChange={(e) => setRating(e.target.value)}>
                <option>G</option>
                <option>PG</option>
                <option>PG-13</option>
                <option>R</option>
                <option>NC-17</option>
                <option>NR</option>
            </select>
            <input type="number" placeholder="Price" value={price} onChange={(e) => setPrice(e.target.value)} required />
            <button type="submit">Save DVD</button>
        </form>
    );
}

export default DvdForm;