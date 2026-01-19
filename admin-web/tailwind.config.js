/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        primary: {
          50: '#eff6ff',
          100: '#dbeafe',
          200: '#bfdbfe',
          300: '#93c5fd',
          400: '#60a5fa',
          500: '#4F46E5',
          600: '#4338CA',
          700: '#3730A3',
          800: '#312E81',
          900: '#1e1b4b',
        },
        accent: {
          orange: '#FFA94D',
          pink: '#FF6B95',
          cyan: '#06B6D4',
          green: '#10B981',
        }
      },
    },
  },
  plugins: [],
}
