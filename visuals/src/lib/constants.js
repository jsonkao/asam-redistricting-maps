export const colors = {
	black: '#9fd400',
	hispanic: '#ffaa00',
	asian: '#ff0000',
	white: '#73B2FF'
}; // from Racial Dot Map, see https://github.com/unorthodox123/RacialDotMap/blob/master/dotmap.pde#L168

export const levels = ['44', '99', 'ee'];
export const groups = ['asian', 'black', 'hispanic', 'white'];
export const periods = ['1990_earlier', '1990_1999', '2000_2009', '2010_later'];

export const translate = false;

export const variablesLong = {
	hhlang: 'Proportion of households that speak an Asian language and are LEP',
	income: 'Median household income',
	graduates: 'Proportion of people who graduated >= high school',
	families: "Proportion of families who receive gov't benefits",
	asiaentry: 'Dominant entry period for Asian families',
	workers: 'Proportion of workers who take public transportation',
	cvap: 'Citizen voting age population by race',
	pop: 'Population by race' + (translate ? ' / 人口划分: 各种族群' : ''),
};

export const seqColors = ['#fee5d9', '#fcbba1', '#fc9272', '#fb6a4a', '#de2d26'] || [
	'#ecf2f7',
	'#cabed8',
	'#aa8ab6',
	'#8b5794',
	'#6d2c71',
	'#4b134c'
];

export const schemeBlues = ['#eff3ff', '#c6dbef', '#9ecae1', '#6baed6', '#3182bd', '#08519c'];

// Directly copied from output of `python3 preprocess.py -get-ideals`, then formatted
export const idealValues = {
	assembly_letters: 134675,
	assembly_names: 134626,
	senate_letters: 320655,
	senate_names: 321190,
	congress_letters: 776971,
	congress_names: 776971
};

export const views = {
	'Queens, Western': [250, 320, 400, 350],
	Queens: [200, 290, 775, 600],
	Chinatown: [80, 500, 300, 220],
	'Chinatown Wide': [80, 430, 500, 600],
	Brooklyn: [20, 670, 600, 520],
	// 'South Brooklyn': [20, 760, 500, 426],
	'All of NYC': [20, 0, 975, 1220]
};

export const focusDistricts = {
	assembly: '49 47 45 41 51 48'.split(' ').map((x) => +x),
	assembly_letters: 'AU AW AS AT AV AY AO'.split(' '),
	assembly_names: 'BNSNHRST GRAVESEND MADFLAT CNYSHPSHD BAYDYKER SUNSET BOROUGHPARK'.split(' '),
	senate: '20 17 23 22 19'.split(' ').map((x) => +x),
	senate_letters: 'G AA Q AC'.split(' '),
	senate_names: 'SNSTPRK BAYGRAVES MADMID STATENCONEY FLATBUSH'.split(' ')
};

if (typeof window === 'undefined') {
	const [x, y, w, h] = views[Object.keys(views)[0]];
	console.log(`${x},${y},${x + w},${y + h}`);
}