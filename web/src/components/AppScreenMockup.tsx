'use client'

import { motion } from 'framer-motion'

const kids = [
  { name: 'Emma', emoji: '👧', color: '#F472B6', balance: 47.50 },
  { name: 'Jake', emoji: '👦', color: '#60A5FA', balance: 23.00 },
  { name: 'Lily', emoji: '🧒', color: '#A78BFA', balance: 85.25 },
]

const transactions = [
  { kid: 'Emma', amount: 10, note: 'Weekly allowance 💵', type: 'add', time: '2m ago' },
  { kid: 'Jake', amount: -5, note: 'Ice cream 🍦', type: 'spend', time: '1h ago' },
  { kid: 'Lily', amount: 20, note: 'Birthday from Grandma 🎂', type: 'add', time: '3h ago' },
]

export function AppScreenMockup() {
  return (
    <div className="flex h-full flex-col bg-gradient-to-b from-gray-50 to-gray-100 p-4">
      {/* Status bar mockup */}
      <div className="flex items-center justify-between px-2 py-1 text-[10px] font-medium text-gray-600">
        <span>9:41</span>
        <div className="flex items-center gap-1">
          <span>5G</span>
          <svg className="h-3 w-3" viewBox="0 0 24 24" fill="currentColor">
            <path d="M12 3L20 21H4L12 3Z" />
          </svg>
          <div className="flex h-2.5 w-5 items-center rounded-sm border border-gray-600 p-0.5">
            <div className="h-full w-full rounded-sm bg-emerald-500" />
          </div>
        </div>
      </div>

      {/* Header */}
      <motion.div
        initial={{ opacity: 0, y: -10 }}
        animate={{ opacity: 1, y: 0 }}
        className="mt-3 text-center"
      >
        <h1 className="text-lg font-bold text-gray-900">My Kids 👨‍👩‍👧‍👦</h1>
      </motion.div>

      {/* Kids cards */}
      <div className="mt-4 space-y-2.5">
        {kids.map((kid, index) => (
          <motion.div
            key={kid.name}
            initial={{ opacity: 0, x: -20 }}
            animate={{ opacity: 1, x: 0 }}
            transition={{ delay: 0.1 + index * 0.1 }}
            className="flex items-center justify-between rounded-2xl bg-white p-3 shadow-sm"
          >
            <div className="flex items-center gap-2.5">
              <motion.div
                whileHover={{ scale: 1.1 }}
                className="flex h-10 w-10 items-center justify-center rounded-full text-xl"
                style={{ backgroundColor: kid.color + '25' }}
              >
                {kid.emoji}
              </motion.div>
              <span className="text-sm font-semibold text-gray-900">{kid.name}</span>
            </div>
            <motion.div
              initial={{ scale: 0.8 }}
              animate={{ scale: 1 }}
              transition={{ delay: 0.3 + index * 0.1, type: "spring" }}
              className="text-right"
            >
              <span className="text-lg font-bold text-emerald-600">
                ${kid.balance.toFixed(2)}
              </span>
            </motion.div>
          </motion.div>
        ))}
      </div>

      {/* Recent Activity */}
      <motion.div
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        transition={{ delay: 0.5 }}
        className="mt-4"
      >
        <h2 className="mb-2 text-[10px] font-bold uppercase tracking-wider text-gray-400">
          Recent Activity
        </h2>
        <div className="space-y-1.5">
          {transactions.map((tx, index) => (
            <motion.div
              key={index}
              initial={{ opacity: 0, x: -10 }}
              animate={{ opacity: 1, x: 0 }}
              transition={{ delay: 0.6 + index * 0.08 }}
              className="flex items-center justify-between rounded-xl bg-white px-2.5 py-2 shadow-sm"
            >
              <div className="flex flex-col">
                <div className="flex items-center gap-1">
                  <span className="text-xs font-medium text-gray-900">
                    {tx.kid}
                  </span>
                  <span className="text-[9px] text-gray-400">{tx.time}</span>
                </div>
                <span className="text-[10px] text-gray-500">{tx.note}</span>
              </div>
              <motion.span
                initial={{ scale: 0 }}
                animate={{ scale: 1 }}
                transition={{ delay: 0.8 + index * 0.1, type: "spring" }}
                className={`text-xs font-bold ${
                  tx.type === 'add' ? 'text-emerald-500' : 'text-red-400'
                }`}
              >
                {tx.type === 'add' ? '+' : '-'}${Math.abs(tx.amount).toFixed(2)}
              </motion.span>
            </motion.div>
          ))}
        </div>
      </motion.div>

      {/* Quick add buttons mockup */}
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ delay: 1 }}
        className="mt-auto pt-3"
      >
        <div className="flex justify-center gap-2">
          {[1, 5, 10, 20].map((amount, index) => (
            <motion.div
              key={amount}
              initial={{ scale: 0 }}
              animate={{ scale: 1 }}
              transition={{ delay: 1.1 + index * 0.05, type: "spring", stiffness: 300 }}
              whileHover={{ scale: 1.1, y: -2 }}
              className="flex h-9 w-9 cursor-pointer items-center justify-center rounded-full bg-emerald-500 text-xs font-bold text-white shadow-md shadow-emerald-500/30"
            >
              +${amount}
            </motion.div>
          ))}
        </div>
        <p className="mt-2 text-center text-[8px] text-gray-400">Tap to add money</p>
      </motion.div>
    </div>
  )
}
