import '../styles/globals.css'
import Link from 'next/link'

function MyApp({ Component, pageProps }) {
  return (
    <div>
      <nav className="border-b p-6">
        <p></p>
        <div>
          <Link>
            <a></a>
          </Link>
          <Link>
            <a></a>
          </Link>
          <Link>
            <a></a>
          </Link>
          <Link>
            <a></a>
          </Link>
        </div>
      </nav>
      <Component {...pageProps} />
    </div>
  )
}

export default MyApp
