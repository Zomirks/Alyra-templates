'use client';
import { useState, useEffect } from "react";

const JeuPage = () => {

    const [number, setNumber] = useState(0);

    const increment = () => {
        setNumber(number + 1);
    }

    useEffect(() => {
        console.log('number a changé');
    }, [number]);

    useEffect(() => {
        console.log('La page est chargée');
    }, []);

    useEffect(() => {
        console.log('Quelque chose a changé');
    });

    useEffect(() => {
        return () => {
            console.log('Le composant est démonté');
        }
    }), [];
    
    return (
        <>
            <div>{number}</div>
            <button onClick={increment}>Incrémenter</button>
        </>
    )
}
export default JeuPage