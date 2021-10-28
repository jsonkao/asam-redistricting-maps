export const pct = (x, decimals = 1) =>
	Math.round(x * Math.pow(10, decimals + 2)) / Math.pow(10, decimals) + '%';

export const money = (x) => '$' + Math.round(x / 1000) + 'k';

export const capitalize = (s) => s.charAt(0).toUpperCase() + s.slice(1);

export const isNum = (x) => !isNaN(x) && x !== null;

export const id = (f) => f.properties.GEOID;

export const district = (f) => f.properties.DISTRICT;

export const xor = (t, u) => (t && !u) || (u && !t);

export const planTitle = (a) => {
	const [plan, district] = a.split(',');
	const words = plan.split('_')
	return (words.length === 1 ? '' : `“${capitalize(words[1])}” `) + capitalize(words[0]) + ' ' + district;
};

export const planDesc = (plan) => {
	const words = plan.split('_');
	return (words.length === 1 ? '' : `“${capitalize(words[1])}” `) + capitalize(words[0]);
};

export function unpackAttributes(obj) {
	const geoms = obj.geometries;
	const attributes = geoms[0].properties.fields;
	for (let i = 0; i < geoms.length; i++) {
		const table = {};
		geoms[i].properties = geoms[i].properties.d.split(',')
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
