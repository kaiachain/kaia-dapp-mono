import { type ReactNode } from 'react'
import { headers } from 'next/headers' 
import { cookieToInitialState } from 'wagmi' 

import { config } from './config'
import { Providers } from './providers'

export default function Layout({ children }: { children: ReactNode }) {
  const initialState = cookieToInitialState( 
    config, 
    headers().get('cookie') 
  ) 
  return (
    <html lang="en">
      <body>
        <Providers initialState={initialState}> 
          {children}
        </Providers>
      </body>
    </html>
  )
}