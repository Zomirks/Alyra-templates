import Link from "next/link";

const Header = () => {
  return (
    <>
      <div className="flex items-center justify-between p-5 bg-sky-400">
        <nav className="w-xs">
          <ul className="flex items-center justify-center">
            <li>
              <Link href="/">Accueil</Link>
            </li>
            <li>
              <Link href="/about">About</Link>
            </li>
            <li>
              <Link href="/contact">Contact</Link>
            </li>
          </ul>
        </nav>
      </div>
    </>
  )
}
export default Header