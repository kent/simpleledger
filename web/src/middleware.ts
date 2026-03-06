import { NextResponse } from 'next/server'
import type { NextRequest } from 'next/server'

import { siteHost, wwwSiteHost } from '@/lib/site'

export function middleware(request: NextRequest) {
  const forwardedHost = request.headers.get('x-forwarded-host')
  const forwardedProto = request.headers.get('x-forwarded-proto')
  const protocol = forwardedProto ?? request.nextUrl.protocol.replace(':', '')
  const host = (forwardedHost ?? request.headers.get('host') ?? '').split(':')[0]
  const canonicalHost = host === wwwSiteHost ? siteHost : host

  if (host === canonicalHost && protocol === 'https') {
    return NextResponse.next()
  }

  const url = new URL(
    `${request.nextUrl.pathname}${request.nextUrl.search}`,
    `https://${canonicalHost}`,
  )

  return NextResponse.redirect(url, 308)
}

export const config = {
  matcher: ['/((?!_next/static|_next/image|favicon.ico|.*\\..*).*)'],
}
