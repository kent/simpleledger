import clsx from 'clsx'

export function Logomark({
  className,
  ...props
}: React.ComponentPropsWithoutRef<'svg'>) {
  return (
    <svg
      viewBox="0 0 40 40"
      aria-hidden="true"
      className={clsx('h-10 w-10', className)}
      {...props}
    >
      <circle cx="20" cy="20" r="20" className="fill-emerald-500" />
      <text
        x="20"
        y="28"
        textAnchor="middle"
        className="fill-white text-xl font-bold"
        style={{ fontSize: '24px' }}
      >
        $
      </text>
    </svg>
  )
}

export function Logo({
  className,
  ...props
}: React.ComponentPropsWithoutRef<'div'>) {
  return (
    <div className={clsx('flex items-center gap-2', className)} {...props}>
      <Logomark />
      <span className="text-xl font-bold text-gray-900">Munnies</span>
    </div>
  )
}
