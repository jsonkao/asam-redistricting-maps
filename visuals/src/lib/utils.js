export const pct = (x, decimals = 1) =>
	Math.round(x * Math.pow(10, decimals + 2)) / Math.pow(10, decimals) + '%';

export const money = (x) => '$' + Math.round(x / 1000) + 'k';

export const capitalize = (s) => s.charAt(0).toUpperCase() + s.slice(1);

export const isNum = (x) => !isNaN(x) && x !== null;

export const id = (f) => f.properties.GEOID;

export const district = (f) => f.properties.DISTRICT;

export const xor = (t, u) => (t && !u) || (u && !t);

export const planTitle = (plan) => {
	const words = plan.split('_');
	return capitalize(words[0]) + (words.length === 1 ? '' : `, “${capitalize(words[1])}”`);
};

export function unpackAttributes(obj) {
	const geoms = obj.geometries;
	const attributes = geoms[0].properties.fields;
	for (let i = 0; i < geoms.length; i++) {
		const table = {};
		for (let j = 0; j < attributes.length; j++) {
			table[attributes[j]] = geoms[i].properties[j];
		}
		geoms[i].properties = table;
	}
	return obj;
}
