export const pct = (x, decimals = 2) => Math.round(x * Math.pow(10, decimals + 2)) / Math.pow(10, decimals) + '%';

export const money = x => '$' + Math.round(x / 1000) + 'k'

export const capitalize = s => s.charAt(0).toUpperCase() + s.slice(1)