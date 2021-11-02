import { base } from '$app/paths';
import { geoPath } from 'd3-geo';
import { feature, mesh as topoMesh } from 'topojson-client';

export const pct = (x, decimals = 1) =>
	Math.round(x * Math.pow(10, decimals + 2)) / Math.pow(10, decimals) + '%';

const D = (x) => Object.values(x.properties)[0];

export const money = (x) => '$' + Math.round(x / 1000) + 'k';

export const capitalize = (s) => s.charAt(0).toUpperCase() + s.slice(1);

export const isNum = (x) => !isNaN(x) && x !== null;

export const id = (f) => f.properties.GEOID;

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
	return (words.length === 1 ? 'Current ' : `“${capitalize(words[1])}” `) + capitalize(words[0]);
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

// Works for geometries MultiPolygons, Polygons, and MultiLineStrings and features
// with those geometries
export function reduceCoordinatePrecision(d) {
	let g, f;
	if (d.type === 'Feature') {
		g = d.geometry;
		f = d;
	} else if (['MultiPolygon', 'Polygon', 'MultiLineString'].includes(d.type)) {
		g = d;
	}

	const coords = g.type === 'MultiPolygon' ? g.coordinates : [g.coordinates];
	for (let p = 0; p < coords.length; p++) {
		const polygon = coords[p];
		for (let l = 0; l < polygon.length; l++) {
			const ring = polygon[l];
			for (let n = 0; n < ring.length; n++) {
				const position = ring[n];
				for (let i = 0; i < position.length; i++) {
					const number = position[i];
					coords[p][l][n][i] = +number.toFixed(1);
				}
			}
		}
	}

	const geometry = {
		type: g.type,
		coordinates: g.type === 'MultiPolygon' ? coords : coords[0]
	};
	return f ? { ...f, geometry } : geometry;
}

export const path = geoPath();

export async function getPlansMeshes() {
	const topoData = await (await fetch(`${base}/output_assembly_senate.topojson`)).json();
	return Object.keys(topoData.objects).reduce((acc, k) => {
		acc[k] = path(topoMesh(topoData, topoData.objects[k], (a, b) => D(a) !== D(b)));
		return acc;
	}, {});
}

export async function getPoints() {
	const topoData = await (await fetch(`${base}/points.topojson`)).json();
	return feature(topoData, topoData.objects.layer).features;
}

export async function getCongressMeshes() {
	const req = await fetch(`${base}/output_congress.topojson`);
	const topoData = await req.json();
	return Object.keys(topoData.objects).reduce((acc, k) => {
		acc[k] = path(topoMesh(topoData, topoData.objects[k], (a, b) => D(a) !== D(b)));
		return acc;
	}, {});
}