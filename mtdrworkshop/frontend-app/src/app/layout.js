import './globals.css'
import { Inter } from 'next/font/google'
import styles from "@/app/page.module.css";

const inter = Inter({ subsets: ['latin'] })

export const metadata = {
  title: 'My To-Do React',
  description: 'My To-Do List React Application',
}


let displayDev = () => {
  if (process.env.NODE_ENV === 'development') {
    return (<header className={"header"}>Development Version</header>)
  }
}
export default function RootLayout({ children }) {
  return (
    <html lang="en">
      <body className={inter.className}>
      {displayDev()}
      {children}
      </body>

    </html>
  )
}
