'use client';
import { useTheme } from "../context/useTheme";

const ContactPage = () => {
  const { darkMode, toggleTheme } = useTheme();

  return (
    <div>
      <h1>ContactPage</h1>
      <button onClick={toggleTheme}>
        {darkMode ? "Passer en mode clair" : "Passer en mode sombre"}  
      </button>  
    </div>
  )
}
export default ContactPage