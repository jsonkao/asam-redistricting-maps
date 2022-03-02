import { base } from '$app/paths';

export const pct = (x, decimals = 1) =>
	Math.round(x * Math.pow(10, decimals + 2)) / Math.pow(10, decimals) + '%';

export const D = (x) => Object.values(x.properties)[0];

export const money = (x) => '$' + Math.round(x / 1000) + 'k';

export const capitalize = (s) => s.charAt(0).toUpperCase() + s.slice(1);

export const isNum = (x) => !isNaN(x) && x !== null;

export const xor = (t, u) => (t && !u) || (u && !t);

export const deviation = (x) => `${Math.abs(x)} ${x < 0 ? 'below' : 'above'}`;

export const planTitle = (a) => {
	const [plan, district] = a.split(',');
	const words = plan.split('_');
	return (
		(words.length === 1 ? '' : `“${capitalize(words[1])}” `) + capitalize(words[0]) + ' ' + district
	);
};

export const planDesc = (plan) => {
	const words = plan.split('_');
	return (words.length === 1 ? 'Current ' : `“${words[1] === 'latfor' ? 'LATFOR' : capitalize(words[1])}” `) + capitalize(words[0]);
};

export function unpackAttributes(obj) {
	const geoms = obj.geometries;
	const attributes = geoms[0].properties.fields;
	for (let i = 0; i < geoms.length; i++) {
		const table = {};
		geoms[i].properties = geoms[i].properties.d.split(',');
		for (let j = 0; j < attributes.length; j++) {
			let v = geoms[i].properties[j];
			if (v === '') v = null;
			else if (!isNaN(+v) && attributes[j] !== 'GEOID') v = +v;
			table[attributes[j]] = v;
		}
		geoms[i].properties = table;
	}
	return obj;
}

export async function getPlansMeshes() {
	return await (await fetch(`${base}/output_assembly_senate_unity.topojson`)).json();
}

export function hexToRGB(hex) {
	if (!hex.startsWith('#')) {
		return hex;
	}
	let r = parseInt(hex.slice(1, 3), 16);
	let g = parseInt(hex.slice(3, 5), 16);
	let b = parseInt(hex.slice(5, 7), 16);
	if (hex.length > 7) {
			return "rgba(" + r + ", " + g + ", " + b + ", " + (parseInt(hex.slice(7, 9), 16) / 255) + ")";
	} else {
			return "rgb(" + r + ", " + g + ", " + b + ")";
	}
}

export function readCSV(text) {
	const rows = text.split('\n');
	const keys = rows.shift().split(',');
	return rows.map(row => row.split(',')).map(row => keys.reduce((acc, key, i) => {
		acc[key] = row[i];
		if (key.includes('vap') || key.includes('pop')) acc[key] = +acc[key];
		return acc;
	}, {}))
}