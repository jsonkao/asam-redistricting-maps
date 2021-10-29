var Bt=Object.defineProperty,Mt=Object.defineProperties;var St=Object.getOwnPropertyDescriptors;var Tl=Object.getOwnPropertySymbols;var At=Object.prototype.hasOwnProperty,Ct=Object.prototype.propertyIsEnumerable;var Dl=(s,e,l)=>e in s?Bt(s,e,{enumerable:!0,configurable:!0,writable:!0,value:l}):s[e]=l,Il=(s,e)=>{for(var l in e||(e={}))At.call(e,l)&&Dl(s,l,e[l]);if(Tl)for(var l of Tl(e))Ct.call(e,l)&&Dl(s,l,e[l]);return s},Ol=(s,e)=>Mt(s,St(e));import{J as Nl,K as Lt,L as yl,M as Ut,S as zt,i as Rt,s as qt,e as P,t as N,c as V,a as j,g as y,d as _,f as z,H as u,h as ge,l as Ve,k as M,n as S,b as k,N as ce,O as fe,P as Oe,Q as ul,I as hl,R as Ke,T as je,U as ke,V as Ee,W as Qe,X as Bl,Y as Ml,Z as Ht,x as ue,u as Te,w as Xe,_ as Wt,$ as Gt,a0 as Ft,a1 as Jt,a2 as Kt,a3 as Ye,a4 as _l,a5 as Ce,r as Ze,a6 as Qt,a7 as Sl}from"../chunks/vendor-a9cad297.js";import{u as Xt,c as ll,p as Al,a as De,m as $e,d as Cl,i as Ie,b as Ll,x as Yt,e as Zt}from"../chunks/utils-071fc457.js";const bl={black:"#9fd400",hispanic:"#ffaa00",asian:"#ff0000",white:"#73B2FF"},pl=["44","99","ee"],Re=["asian","black","hispanic","white"],qe=["1990_earlier","1990_1999","2000_2009","2010_later"],dl={hhlang:"Proportion of households that speak an Asian language and are LEP",income:"Median household income",graduates:"Proportion of people who graduated >= high school",families:"Proportion of families who receive gov't benefits",asiaentry:"Dominant entry period for Asian families",workers:"Proportion of workers who take public transportation",cvap:"Citizen voting age population by race",pop:"Population by race"},gl=["#fee5d9","#fcbba1","#fc9272","#fb6a4a","#de2d26"],xe=["#eff3ff","#c6dbef","#9ecae1","#6baed6","#3182bd","#08519c"],vl={assembly_letters:134675,assembly_names:134626,senate_letters:320655,senate_names:321190,congress_letters:776971,congress_names:776971};function Ul(s,e,l){const t=s.slice();return t[66]=e[l],t}function zl(s,e,l){const t=s.slice();return t[69]=e[l].properties,t[70]=e[l].geometry.coordinates[0],t[71]=e[l].geometry.coordinates[1],t}function Rl(s,e,l){const t=s.slice();return t[74]=e[l].outline,t}function ql(s,e,l){const t=s.slice();return t[77]=e[l],t[79]=l,t}function Hl(s,e,l){const t=s.slice();return t[80]=e[l].name,t[26]=e[l].stats,t[79]=l,t}function Wl(s,e,l){const t=s.slice();return t[82]=e[l],t}function Gl(s,e,l){const t=s.slice();return t[85]=e[l],t}function Fl(s,e,l){const t=s.slice();return t[88]=e[l],t}function Jl(s,e,l){const t=s.slice();return t[91]=e[l],t}function Kl(s,e,l){const t=s.slice();return t[94]=e[l],t}function Ql(s,e,l){const t=s.slice();return t[105]=e[l],t}function Xl(s,e,l){const t=s.slice();return t[105]=e[l],t[79]=l,t}function Yl(s,e,l){const t=s.slice();return t[69]=e[l],t}function Zl(s,e,l){const t=s.slice();return t[69]=e[l],t[79]=l,t}function $l(s,e,l){const t=s.slice();return t[82]=e[l],t}function xl(s,e,l){const t=s.slice();return t[99]=e[l],t}function et(s,e,l){const t=s.slice();return t[69]=e[l],t}function lt(s,e,l){const t=s.slice();return t[66]=e[l],t}function tt(s,e,l){const t=s.slice();return t[66]=e[l],t}function st(s){let e,l=(dl[s[66]]||s[66])+"",t,a;return{c(){e=P("option"),t=N(l),this.h()},l(r){e=V(r,"OPTION",{});var n=j(e);t=y(n,l),n.forEach(_),this.h()},h(){e.__value=a=s[66],e.value=e.__value},m(r,n){z(r,e,n),u(e,t)},p(r,n){n[0]&8&&l!==(l=(dl[r[66]]||r[66])+"")&&ge(t,l),n[0]&8&&a!==(a=r[66])&&(e.__value=a,e.value=e.__value)},d(r){r&&_(e)}}}function ot(s){let e,l=(dl[s[66]]||s[66])+"",t,a;return{c(){e=P("option"),t=N(l),this.h()},l(r){e=V(r,"OPTION",{});var n=j(e);t=y(n,l),n.forEach(_),this.h()},h(){e.__value=a=s[66],e.value=e.__value},m(r,n){z(r,e,n),u(e,t)},p(r,n){n[0]&16&&l!==(l=(dl[r[66]]||r[66])+"")&&ge(t,l),n[0]&16&&a!==(a=r[66])&&(e.__value=a,e.value=e.__value)},d(r){r&&_(e)}}}function nt(s){let e,l=["past","present"],t=[];for(let a=0;a<2;a+=1)t[a]=at(et(s,l,a));return{c(){for(let a=0;a<2;a+=1)t[a].c();e=Ve()},l(a){for(let r=0;r<2;r+=1)t[r].l(a);e=Ve()},m(a,r){for(let n=0;n<2;n+=1)t[n].m(a,r);z(a,e,r)},p(a,r){if(r[0]&512){l=["past","present"];let n;for(n=0;n<2;n+=1){const o=et(a,l,n);t[n]?t[n].p(o,r):(t[n]=at(o),t[n].c(),t[n].m(e.parentNode,e))}for(;n<2;n+=1)t[n].d(1)}},d(a){fe(t,a),a&&_(e)}}}function at(s){let e,l,t,a=ll(s[69])+"",r,n,o,c;return{c(){e=P("label"),l=P("input"),t=M(),r=N(a),n=M(),this.h()},l(i){e=V(i,"LABEL",{});var d=j(e);l=V(d,"INPUT",{type:!0,name:!0}),t=S(d),r=y(d,a),n=S(d),d.forEach(_),this.h()},h(){k(l,"type","radio"),k(l,"name","period"),l.__value=s[69],l.value=l.__value,s[44][0].push(l)},m(i,d){z(i,e,d),u(e,l),l.checked=l.__value===s[9],u(e,t),u(e,r),u(e,n),o||(c=ce(l,"change",s[43]),o=!0)},p(i,d){d[0]&512&&(l.checked=l.__value===i[9])},d(i){i&&_(e),s[44][0].splice(s[44][0].indexOf(l),1),o=!1,c()}}}function it(s){let e,l,t=(s[11]?"pct. asian":"pluralities")+"",a,r,n;return{c(){e=P("button"),l=N("Show "),a=N(t),this.h()},l(o){e=V(o,"BUTTON",{class:!0});var c=j(e);l=y(c,"Show "),a=y(c,t),c.forEach(_),this.h()},h(){k(e,"class","plurality-toggle svelte-1jfuj1x")},m(o,c){z(o,e,c),u(e,l),u(e,a),r||(n=ce(e,"click",s[45]),r=!0)},p(o,c){c[0]&2048&&t!==(t=(o[11]?"pct. asian":"pluralities")+"")&&ge(a,t)},d(o){o&&_(e),r=!1,n()}}}function $t(s){let e,l,t=s[25],a=[];for(let o=0;o<t.length;o+=1)a[o]=rt(Xl(s,t,o));let r=s[25],n=[];for(let o=0;o<r.length;o+=1)n[o]=ct(Ql(s,r,o));return{c(){e=P("div");for(let o=0;o<a.length;o+=1)a[o].c();l=M();for(let o=0;o<n.length;o+=1)n[o].c();this.h()},l(o){e=V(o,"DIV",{class:!0,style:!0});var c=j(e);for(let i=0;i<a.length;i+=1)a[i].l(c);l=S(c);for(let i=0;i<n.length;i+=1)n[i].l(c);c.forEach(_),this.h()},h(){k(e,"class","color-legend svelte-1jfuj1x"),je(e,"grid-template-columns","repeat("+(s[3].includes(s[10])?5:6)+", 40px)")},m(o,c){z(o,e,c);for(let i=0;i<a.length;i+=1)a[i].m(e,null);u(e,l);for(let i=0;i<n.length;i+=1)n[i].m(e,null)},p(o,c){if(c[0]&33555464){t=o[25];let i;for(i=0;i<t.length;i+=1){const d=Xl(o,t,i);a[i]?a[i].p(d,c):(a[i]=rt(d),a[i].c(),a[i].m(e,l))}for(;i<a.length;i+=1)a[i].d(1);a.length=t.length}if(c[0]&33554432){r=o[25];let i;for(i=0;i<r.length;i+=1){const d=Ql(o,r,i);n[i]?n[i].p(d,c):(n[i]=ct(d),n[i].c(),n[i].m(e,null))}for(;i<n.length;i+=1)n[i].d(1);n.length=r.length}c[0]&1032&&je(e,"grid-template-columns","repeat("+(o[3].includes(o[10])?5:6)+", 40px)")},d(o){o&&_(e),fe(a,o),fe(n,o)}}}function xt(s){let e,l,t=qe,a=[];for(let o=0;o<t.length;o+=1)a[o]=ft(Zl(s,t,o));let r=qe,n=[];for(let o=0;o<r.length;o+=1)n[o]=ut(Yl(s,r,o));return{c(){e=P("div");for(let o=0;o<a.length;o+=1)a[o].c();l=M();for(let o=0;o<n.length;o+=1)n[o].c();this.h()},l(o){e=V(o,"DIV",{class:!0});var c=j(e);for(let i=0;i<a.length;i+=1)a[i].l(c);l=S(c);for(let i=0;i<n.length;i+=1)n[i].l(c);c.forEach(_),this.h()},h(){k(e,"class","color-legend plurality-legend svelte-1jfuj1x")},m(o,c){z(o,e,c);for(let i=0;i<a.length;i+=1)a[i].m(e,null);u(e,l);for(let i=0;i<n.length;i+=1)n[i].m(e,null)},p(o,c){if(c&0){t=qe;let i;for(i=0;i<t.length;i+=1){const d=Zl(o,t,i);a[i]?a[i].p(d,c):(a[i]=ft(d),a[i].c(),a[i].m(e,l))}for(;i<a.length;i+=1)a[i].d(1);a.length=t.length}if(c&0){r=qe;let i;for(i=0;i<r.length;i+=1){const d=Yl(o,r,i);n[i]?n[i].p(d,c):(n[i]=ut(d),n[i].c(),n[i].m(e,null))}for(;i<n.length;i+=1)n[i].d(1);n.length=r.length}},d(o){o&&_(e),fe(a,o),fe(n,o)}}}function es(s){let e,l,t,a,r,n,o,c,i,d,w,T,b=Re,p=[];for(let g=0;g<b.length;g+=1)p[g]=_t($l(s,b,g));return{c(){e=P("div");for(let g=0;g<p.length;g+=1)p[g].c();l=M(),t=P("p"),a=P("span"),r=N("Weak plurality"),n=M(),o=P("p"),c=M(),i=P("p"),d=N("Majority"),w=M(),T=P("p"),this.h()},l(g){e=V(g,"DIV",{class:!0});var v=j(e);for(let ee=0;ee<p.length;ee+=1)p[ee].l(v);l=S(v),t=V(v,"P",{class:!0});var D=j(t);a=V(D,"SPAN",{});var B=j(a);r=y(B,"Weak plurality"),B.forEach(_),D.forEach(_),n=S(v),o=V(v,"P",{class:!0}),j(o).forEach(_),c=S(v),i=V(v,"P",{class:!0});var K=j(i);d=y(K,"Majority"),K.forEach(_),w=S(v),T=V(v,"P",{class:!0}),j(T).forEach(_),v.forEach(_),this.h()},h(){k(t,"class","col-head svelte-1jfuj1x"),k(o,"class","col-head svelte-1jfuj1x"),k(i,"class","col-head svelte-1jfuj1x"),k(T,"class","col-head svelte-1jfuj1x"),k(e,"class","legend svelte-1jfuj1x")},m(g,v){z(g,e,v);for(let D=0;D<p.length;D+=1)p[D].m(e,null);u(e,l),u(e,t),u(t,a),u(a,r),u(e,n),u(e,o),u(e,c),u(e,i),u(i,d),u(e,w),u(e,T)},p(g,v){if(v&0){b=Re;let D;for(D=0;D<b.length;D+=1){const B=$l(g,b,D);p[D]?p[D].p(B,v):(p[D]=_t(B),p[D].c(),p[D].m(e,l))}for(;D<p.length;D+=1)p[D].d(1);p.length=b.length}},d(g){g&&_(e),fe(p,g)}}}function rt(s){let e;return{c(){e=P("div"),this.h()},l(l){e=V(l,"DIV",{style:!0}),j(e).forEach(_),this.h()},h(){je(e,"background-color",s[3].includes(s[10])?gl[s[79]]:xe[s[79]])},m(l,t){z(l,e,t)},p(l,t){t[0]&1032&&je(e,"background-color",l[3].includes(l[10])?gl[l[79]]:xe[l[79]])},d(l){l&&_(e)}}}function ct(s){let e,l=(s[25][s[25].length-1]<1?De(s[105],0):s[25][s[25].length-1]>1e3?$e(s[105]):s[105])+"",t,a;return{c(){e=P("p"),t=N(l),a=M(),this.h()},l(r){e=V(r,"P",{class:!0});var n=j(e);t=y(n,l),a=S(n),n.forEach(_),this.h()},h(){k(e,"class","svelte-1jfuj1x")},m(r,n){z(r,e,n),u(e,t),u(e,a)},p(r,n){n[0]&33554432&&l!==(l=(r[25][r[25].length-1]<1?De(r[105],0):r[25][r[25].length-1]>1e3?$e(r[105]):r[105])+"")&&ge(t,l)},d(r){r&&_(e)}}}function ft(s){let e;return{c(){e=P("div"),this.h()},l(l){e=V(l,"DIV",{style:!0}),j(e).forEach(_),this.h()},h(){je(e,"background-color",xe[s[79]])},m(l,t){z(l,e,t)},p:hl,d(l){l&&_(e)}}}function ut(s){let e,l=s[69].replace("_","-")+"",t;return{c(){e=P("p"),t=N(l),this.h()},l(a){e=V(a,"P",{class:!0});var r=j(e);t=y(r,l),r.forEach(_),this.h()},h(){k(e,"class","svelte-1jfuj1x")},m(a,r){z(a,e,r),u(e,t)},p:hl,d(a){a&&_(e)}}}function ht(s){let e;return{c(){e=P("div"),this.h()},l(l){e=V(l,"DIV",{style:!0}),j(e).forEach(_),this.h()},h(){je(e,"background-color",bl[s[82]]+s[99])},m(l,t){z(l,e,t)},p:hl,d(l){l&&_(e)}}}function _t(s){let e,l,t=ll(s[82])+"",a,r=pl,n=[];for(let o=0;o<r.length;o+=1)n[o]=ht(xl(s,r,o));return{c(){for(let o=0;o<n.length;o+=1)n[o].c();e=M(),l=P("p"),a=N(t),this.h()},l(o){for(let i=0;i<n.length;i+=1)n[i].l(o);e=S(o),l=V(o,"P",{class:!0});var c=j(l);a=y(c,t),c.forEach(_),this.h()},h(){k(l,"class","row-label svelte-1jfuj1x")},m(o,c){for(let i=0;i<n.length;i+=1)n[i].m(o,c);z(o,e,c),z(o,l,c),u(l,a)},p(o,c){if(c&0){r=pl;let i;for(i=0;i<r.length;i+=1){const d=xl(o,r,i);n[i]?n[i].p(d,c):(n[i]=ht(d),n[i].c(),n[i].m(e.parentNode,e))}for(;i<n.length;i+=1)n[i].d(1);n.length=r.length}},d(o){fe(n,o),o&&_(e),o&&_(l)}}}function pt(s){let e,l,t,a,r,n,o,c,i,d=["assembly","senate","congress"],w=[];for(let p=0;p<3;p+=1)w[p]=gt(Jl(s,d,p));let T=s[19],b=[];for(let p=0;p<T.length;p+=1)b[p]=bt(Gl(s,T,p));return{c(){e=P("div"),l=P("div"),t=P("select");for(let p=0;p<3;p+=1)w[p].c();a=M();for(let p=0;p<b.length;p+=1)b[p].c();this.h()},l(p){e=V(p,"DIV",{class:!0});var g=j(e);l=V(g,"DIV",{class:!0});var v=j(l);t=V(v,"SELECT",{class:!0});var D=j(t);for(let B=0;B<3;B+=1)w[B].l(D);D.forEach(_),v.forEach(_),a=S(g);for(let B=0;B<b.length;B+=1)b[B].l(g);g.forEach(_),this.h()},h(){k(t,"class","svelte-1jfuj1x"),s[18]===void 0&&Oe(()=>s[48].call(t)),k(l,"class","plan-selector svelte-1jfuj1x"),k(e,"class","svelte-1jfuj1x")},m(p,g){z(p,e,g),u(e,l),u(l,t);for(let v=0;v<3;v+=1)w[v].m(t,null);ul(t,s[18]),u(e,a);for(let v=0;v<b.length;v+=1)b[v].m(e,null);o=!0,c||(i=ce(t,"change",s[48]),c=!0)},p(p,g){if(g&0){d=["assembly","senate","congress"];let v;for(v=0;v<3;v+=1){const D=Jl(p,d,v);w[v]?w[v].p(D,g):(w[v]=gt(D),w[v].c(),w[v].m(t,null))}for(;v<3;v+=1)w[v].d(1)}if(g[0]&262144&&ul(t,p[18]),g[0]&76283904|g[1]&16){T=p[19];let v;for(v=0;v<T.length;v+=1){const D=Gl(p,T,v);b[v]?b[v].p(D,g):(b[v]=bt(D),b[v].c(),b[v].m(e,null))}for(;v<b.length;v+=1)b[v].d(1);b.length=T.length}},i(p){o||(Oe(()=>{n&&n.end(1),r=Ye(e,_l,{}),r.start()}),o=!0)},o(p){r&&r.invalidate(),n=Ke(e,_l,{}),o=!1},d(p){p&&_(e),fe(w,p),fe(b,p),p&&n&&n.end(),c=!1,i()}}}function dt(s){let e,l=Zt(s[91]+s[94])+"",t,a;return{c(){e=P("option"),t=N(l),this.h()},l(r){e=V(r,"OPTION",{});var n=j(e);t=y(n,l),n.forEach(_),this.h()},h(){e.__value=a=s[91]+s[94],e.value=e.__value},m(r,n){z(r,e,n),u(e,t)},p:hl,d(r){r&&_(e)}}}function gt(s){let e,l=["","_letters","_names"],t=[];for(let a=0;a<3;a+=1)t[a]=dt(Kl(s,l,a));return{c(){e=P("optgroup");for(let a=0;a<3;a+=1)t[a].c();this.h()},l(a){e=V(a,"OPTGROUP",{label:!0});var r=j(e);for(let n=0;n<3;n+=1)t[n].l(r);r.forEach(_),this.h()},h(){k(e,"label",ll(s[91]))},m(a,r){z(a,e,r);for(let n=0;n<3;n+=1)t[n].m(e,null)},p(a,r){if(r&0){l=["","_letters","_names"];let n;for(n=0;n<3;n+=1){const o=Kl(a,l,n);t[n]?t[n].p(o,r):(t[n]=dt(o),t[n].c(),t[n].m(e,null))}for(;n<3;n+=1)t[n].d(1)}},d(a){a&&_(e),fe(t,a)}}}function vt(s){let e,l,t,a=Al(s[85])+"",r,n,o,c,i,d,w,T,b,p,g,v,D,B,K,ee=$e(s[26][s[85]].income)+(s[23]&&s[18]in vl?"; "+Cl(s[26][s[85]].pop20_total-vl[s[18]]):"")+"",te,ve,he,le;function se(){return s[49](s[85])}let J=Re,W=[];for(let q=0;q<J.length;q+=1)W[q]=mt(Fl(s,J,q));return{c(){e=P("div"),l=P("p"),t=P("i"),r=N(a),n=M(),o=P("table"),c=P("tr"),i=P("th"),d=M(),w=P("th"),T=N("CVAP"),b=M(),p=P("th"),g=N("Pop."),v=M();for(let q=0;q<W.length;q+=1)W[q].c();D=M(),B=P("p"),K=N("Income: "),te=N(ee),ve=M(),this.h()},l(q){e=V(q,"DIV",{class:!0});var A=j(e);l=V(A,"P",{class:!0});var O=j(l);t=V(O,"I",{});var C=j(t);r=y(C,a),C.forEach(_),O.forEach(_),n=S(A),o=V(A,"TABLE",{class:!0});var L=j(o);c=V(L,"TR",{class:!0});var R=j(c);i=V(R,"TH",{class:!0}),j(i).forEach(_),d=S(R),w=V(R,"TH",{class:!0});var _e=j(w);T=y(_e,"CVAP"),_e.forEach(_),b=S(R),p=V(R,"TH",{class:!0});var G=j(p);g=y(G,"Pop."),G.forEach(_),R.forEach(_),v=S(L);for(let F=0;F<W.length;F+=1)W[F].l(L);L.forEach(_),D=S(A),B=V(A,"P",{class:!0});var oe=j(B);K=y(oe,"Income: "),te=y(oe,ee),oe.forEach(_),ve=S(A),A.forEach(_),this.h()},h(){k(l,"class","svelte-1jfuj1x"),k(i,"class","svelte-1jfuj1x"),k(w,"class","svelte-1jfuj1x"),k(p,"class","svelte-1jfuj1x"),k(c,"class","svelte-1jfuj1x"),k(o,"class","svelte-1jfuj1x"),k(B,"class","table-footer svelte-1jfuj1x"),k(e,"class","district-aggregate svelte-1jfuj1x")},m(q,A){z(q,e,A),u(e,l),u(l,t),u(t,r),u(e,n),u(e,o),u(o,c),u(c,i),u(c,d),u(c,w),u(w,T),u(c,b),u(c,p),u(p,g),u(o,v);for(let O=0;O<W.length;O+=1)W[O].m(o,null);u(e,D),u(e,B),u(B,K),u(B,te),u(e,ve),he||(le=ce(l,"click",se),he=!0)},p(q,A){if(s=q,A[0]&524288&&a!==(a=Al(s[85])+"")&&ge(r,a),A[0]&67633152){J=Re;let O;for(O=0;O<J.length;O+=1){const C=Fl(s,J,O);W[O]?W[O].p(C,A):(W[O]=mt(C),W[O].c(),W[O].m(o,null))}for(;O<W.length;O+=1)W[O].d(1);W.length=J.length}A[0]&76283904&&ee!==(ee=$e(s[26][s[85]].income)+(s[23]&&s[18]in vl?"; "+Cl(s[26][s[85]].pop20_total-vl[s[18]]):"")+"")&&ge(te,ee)},d(q){q&&_(e),fe(W,q),he=!1,le()}}}function mt(s){let e,l,t=ll(s[88])+"",a,r,n,o=De(s[26][s[85]]["cvap19"+s[88]])+"",c,i,d,w=De(s[26][s[85]]["pop20"+s[88]])+"",T,b;return{c(){e=P("tr"),l=P("td"),a=N(t),r=M(),n=P("td"),c=N(o),i=M(),d=P("td"),T=N(w),b=M(),this.h()},l(p){e=V(p,"TR",{class:!0});var g=j(e);l=V(g,"TD",{class:!0});var v=j(l);a=y(v,t),v.forEach(_),r=S(g),n=V(g,"TD",{class:!0});var D=j(n);c=y(D,o),D.forEach(_),i=S(g),d=V(g,"TD",{class:!0});var B=j(d);T=y(B,w),B.forEach(_),b=S(g),g.forEach(_),this.h()},h(){k(l,"class","svelte-1jfuj1x"),k(n,"class","svelte-1jfuj1x"),k(d,"class","svelte-1jfuj1x"),k(e,"class","svelte-1jfuj1x")},m(p,g){z(p,e,g),u(e,l),u(l,a),u(e,r),u(e,n),u(n,c),u(e,i),u(e,d),u(d,T),u(e,b)},p(p,g){g[0]&67633152&&o!==(o=De(p[26][p[85]]["cvap19"+p[88]])+"")&&ge(c,o),g[0]&67633152&&w!==(w=De(p[26][p[85]]["pop20"+p[88]])+"")&&ge(T,w)},d(p){p&&_(e)}}}function bt(s){let e=s[85].split(",")[0].split("_")[0]===s[18].split("_")[0],l,t=e&&vt(s);return{c(){t&&t.c(),l=Ve()},l(a){t&&t.l(a),l=Ve()},m(a,r){t&&t.m(a,r),z(a,l,r)},p(a,r){r[0]&786432&&(e=a[85].split(",")[0].split("_")[0]===a[18].split("_")[0]),e?t?t.p(a,r):(t=vt(a),t.c(),t.m(l.parentNode,l)):t&&(t.d(1),t=null)},d(a){t&&t.d(a),a&&_(l)}}}function jt(s){let e,l,t,a,r,n,o,c,i,d,w=s[15],T=[];for(let b=0;b<w.length;b+=1)T[b]=Et(Hl(s,w,b));return{c(){e=P("div");for(let b=0;b<T.length;b+=1)T[b].c();l=M(),t=P("button"),a=P("b"),r=N("[SAVE]"),this.h()},l(b){e=V(b,"DIV",{class:!0});var p=j(e);for(let D=0;D<T.length;D+=1)T[D].l(p);l=S(p),t=V(p,"BUTTON",{style:!0});var g=j(t);a=V(g,"B",{});var v=j(a);r=y(v,"[SAVE]"),v.forEach(_),g.forEach(_),p.forEach(_),this.h()},h(){je(t,"font-size","13px"),k(e,"class","svelte-1jfuj1x")},m(b,p){z(b,e,p);for(let g=0;g<T.length;g+=1)T[g].m(e,null);u(e,l),u(e,t),u(t,a),u(a,r),c=!0,i||(d=ce(t,"click",s[33]),i=!0)},p(b,p){if(p[0]&32768|p[1]&2){w=b[15];let g;for(g=0;g<w.length;g+=1){const v=Hl(b,w,g);T[g]?T[g].p(v,p):(T[g]=Et(v),T[g].c(),T[g].m(e,l))}for(;g<T.length;g+=1)T[g].d(1);T.length=w.length}},i(b){c||(Oe(()=>{o&&o.end(1),n=Ye(e,_l,{}),n.start()}),c=!0)},o(b){n&&n.invalidate(),o=Ke(e,_l,{}),c=!1},d(b){b&&_(e),fe(T,b),b&&o&&o.end(),i=!1,d()}}}function kt(s){let e,l,t=ll(s[82])+"",a,r,n=De(s[26][`prop_${s[82]}`])+"",o;return{c(){e=P("p"),l=N("Pct. "),a=N(t),r=N(": "),o=N(n),this.h()},l(c){e=V(c,"P",{class:!0});var i=j(e);l=y(i,"Pct. "),a=y(i,t),r=y(i,": "),o=y(i,n),i.forEach(_),this.h()},h(){k(e,"class","svelte-1jfuj1x")},m(c,i){z(c,e,i),u(e,l),u(e,a),u(e,r),u(e,o)},p(c,i){i[0]&32768&&n!==(n=De(c[26][`prop_${c[82]}`])+"")&&ge(o,n)},d(c){c&&_(e)}}}function Et(s){let e,l,t,a=(s[80]||"COI"+(s[79]+1))+"",r,n,o,c,i,d,w,T,b=$e(s[26].income)+"",p,g,v,D,B=De(s[26].hhlang)+"",K,ee,te,ve,he=De(s[26].benefits)+"",le,se,J;function W(){return s[52](s[79])}let q=["asian"],A=[];for(let O=0;O<1;O+=1)A[O]=kt(Wl(s,q,O));return{c(){e=P("div"),l=P("p"),t=P("i"),r=N(a),n=M(),o=P("button"),c=N("\u{1F5D1}"),i=M();for(let O=0;O<1;O+=1)A[O].c();d=M(),w=P("p"),T=N("Income: "),p=N(b),g=M(),v=P("p"),D=N("Asian and LEP: "),K=N(B),ee=M(),te=P("p"),ve=N("Pct. gov't benefits: "),le=N(he),this.h()},l(O){e=V(O,"DIV",{class:!0});var C=j(e);l=V(C,"P",{class:!0});var L=j(l);t=V(L,"I",{});var R=j(t);r=y(R,a),R.forEach(_),n=S(L),o=V(L,"BUTTON",{});var _e=j(o);c=y(_e,"\u{1F5D1}"),_e.forEach(_),L.forEach(_),i=S(C);for(let me=0;me<1;me+=1)A[me].l(C);d=S(C),w=V(C,"P",{class:!0});var G=j(w);T=y(G,"Income: "),p=y(G,b),G.forEach(_),g=S(C),v=V(C,"P",{class:!0});var oe=j(v);D=y(oe,"Asian and LEP: "),K=y(oe,B),oe.forEach(_),ee=S(C),te=V(C,"P",{class:!0});var F=j(te);ve=y(F,"Pct. gov't benefits: "),le=y(F,he),F.forEach(_),C.forEach(_),this.h()},h(){k(l,"class","svelte-1jfuj1x"),k(w,"class","svelte-1jfuj1x"),k(v,"class","svelte-1jfuj1x"),k(te,"class","svelte-1jfuj1x"),k(e,"class","svelte-1jfuj1x")},m(O,C){z(O,e,C),u(e,l),u(l,t),u(t,r),u(l,n),u(l,o),u(o,c),u(e,i);for(let L=0;L<1;L+=1)A[L].m(e,null);u(e,d),u(e,w),u(w,T),u(w,p),u(e,g),u(e,v),u(v,D),u(v,K),u(e,ee),u(e,te),u(te,ve),u(te,le),se||(J=ce(o,"click",W),se=!0)},p(O,C){if(s=O,C[0]&32768&&a!==(a=(s[80]||"COI"+(s[79]+1))+"")&&ge(r,a),C[0]&32768){q=["asian"];let L;for(L=0;L<1;L+=1){const R=Wl(s,q,L);A[L]?A[L].p(R,C):(A[L]=kt(R),A[L].c(),A[L].m(e,d))}for(;L<1;L+=1)A[L].d(1)}C[0]&32768&&b!==(b=$e(s[26].income)+"")&&ge(p,b),C[0]&32768&&B!==(B=De(s[26].hhlang)+"")&&ge(K,B),C[0]&32768&&he!==(he=De(s[26].benefits)+"")&&ge(le,he)},d(O){O&&_(e),fe(A,O),se=!1,J()}}}function wt(s,e){let l,t,a,r,n;function o(){return e[53](e[79])}function c(){return e[54](e[77])}function i(){return e[55](e[77])}return{key:s,first:null,c(){l=ke("path"),this.h()},l(d){l=Ee(d,"path",{class:!0,d:!0,fill:!0}),j(l).forEach(_),this.h()},h(){k(l,"class","block-group svelte-1jfuj1x"),k(l,"d",t=e[8](e[77])),k(l,"fill",a=e[31](e[77],e[20],e[9],e[11])),Qe(l,"head",e[14][0]===Ie(e[77])),this.first=l},m(d,w){z(d,l,w),r||(n=[ce(l,"click",o),ce(l,"contextmenu",Bl(c)),ce(l,"mousemove",Bl(i))],r=!0)},p(d,w){e=d,w[0]&258&&t!==(t=e[8](e[77]))&&k(l,"d",t),w[0]&1051138&&a!==(a=e[31](e[77],e[20],e[9],e[11]))&&k(l,"fill",a),w[0]&16386&&Qe(l,"head",e[14][0]===Ie(e[77]))},d(d){d&&_(l),r=!1,Ml(n)}}}function Pt(s){let e,l,t,a,r=s[15],n=[];for(let o=0;o<r.length;o+=1)n[o]=Vt(Rl(s,r,o));return{c(){e=ke("g");for(let o=0;o<n.length;o+=1)n[o].c()},l(o){e=Ee(o,"g",{});var c=j(e);for(let i=0;i<n.length;i+=1)n[i].l(c);c.forEach(_)},m(o,c){z(o,e,c);for(let i=0;i<n.length;i+=1)n[i].m(e,null);a=!0},p(o,c){if(c[0]&32768){r=o[15];let i;for(i=0;i<r.length;i+=1){const d=Rl(o,r,i);n[i]?n[i].p(d,c):(n[i]=Vt(d),n[i].c(),n[i].m(e,null))}for(;i<n.length;i+=1)n[i].d(1);n.length=r.length}},i(o){a||(Oe(()=>{t&&t.end(1),l=Ye(e,Ce,{}),l.start()}),a=!0)},o(o){l&&l.invalidate(),t=Ke(e,Ce,{}),a=!1},d(o){o&&_(e),fe(n,o),o&&t&&t.end()}}}function Vt(s){let e,l;return{c(){e=ke("path"),this.h()},l(t){e=Ee(t,"path",{class:!0,d:!0}),j(e).forEach(_),this.h()},h(){k(e,"class","mesh-community svelte-1jfuj1x"),k(e,"d",l=s[74])},m(t,a){z(t,e,a)},p(t,a){a[0]&32768&&l!==(l=t[74])&&k(e,"d",l)},d(t){t&&_(e)}}}function Tt(s){let e,l,t,a,r,n;return{c(){e=ke("g"),l=ke("path"),this.h()},l(o){e=Ee(o,"g",{});var c=j(e);l=Ee(c,"path",{class:!0,d:!0}),j(l).forEach(_),c.forEach(_),this.h()},h(){k(l,"class","mesh-district svelte-1jfuj1x"),k(l,"d",t=s[7][s[18]]),Qe(l,"showPluralities",s[11])},m(o,c){z(o,e,c),u(e,l),n=!0},p(o,c){(!n||c[0]&262272&&t!==(t=o[7][o[18]]))&&k(l,"d",t),c[0]&2048&&Qe(l,"showPluralities",o[11])},i(o){n||(Oe(()=>{r&&r.end(1),a=Ye(e,Ce,{}),a.start()}),n=!0)},o(o){a&&a.invalidate(),r=Ke(e,Ce,{}),n=!1},d(o){o&&_(e),o&&r&&r.end()}}}function Dt(s){let e,l,t,a,r,n;return{c(){e=ke("g"),l=ke("path"),this.h()},l(o){e=Ee(o,"g",{});var c=j(e);l=Ee(c,"path",{class:!0,d:!0}),j(l).forEach(_),c.forEach(_),this.h()},h(){k(l,"class","mesh-district svelte-1jfuj1x"),k(l,"d",t=s[8](s[27](s[56],s[0])))},m(o,c){z(o,e,c),u(e,l),n=!0},p(o,c){(!n||c[0]&262401&&t!==(t=o[8](o[27](o[56],o[0]))))&&k(l,"d",t)},i(o){n||(Oe(()=>{r&&r.end(1),a=Ye(e,Ce,{}),a.start()}),n=!0)},o(o){a&&a.invalidate(),r=Ke(e,Ce,{}),n=!1},d(o){o&&_(e),o&&r&&r.end()}}}function It(s){let e,l,t,a,r=s[2],n=[];for(let o=0;o<r.length;o+=1)n[o]=Nt(zl(s,r,o));return{c(){e=ke("g");for(let o=0;o<n.length;o+=1)n[o].c();this.h()},l(o){e=Ee(o,"g",{class:!0});var c=j(e);for(let i=0;i<n.length;i+=1)n[i].l(c);c.forEach(_),this.h()},h(){k(e,"class","labels svelte-1jfuj1x")},m(o,c){z(o,e,c);for(let i=0;i<n.length;i+=1)n[i].m(e,null);a=!0},p(o,c){if(c[0]&786436|c[1]&16){r=o[2];let i;for(i=0;i<r.length;i+=1){const d=zl(o,r,i);n[i]?n[i].p(d,c):(n[i]=Nt(d),n[i].c(),n[i].m(e,null))}for(;i<n.length;i+=1)n[i].d(1);n.length=r.length}},i(o){a||(Oe(()=>{t&&t.end(1),l=Ye(e,Ce,{}),l.start()}),a=!0)},o(o){l&&l.invalidate(),t=Ke(e,Ce,{}),a=!1},d(o){o&&_(e),fe(n,o),o&&t&&t.end()}}}function Ot(s){let e,l=s[69][s[18]]+"",t,a,r,n,o;function c(){return s[57](s[69])}return{c(){e=ke("text"),t=N(l),this.h()},l(i){e=Ee(i,"text",{x:!0,y:!0,class:!0});var d=j(e);t=y(d,l),d.forEach(_),this.h()},h(){k(e,"x",a=s[70]),k(e,"y",r=s[71]),k(e,"class","svelte-1jfuj1x"),Qe(e,"chosen",s[19].includes(`${s[18]},${s[69][s[18]]}`))},m(i,d){z(i,e,d),u(e,t),n||(o=ce(e,"click",c),n=!0)},p(i,d){s=i,d[0]&262148&&l!==(l=s[69][s[18]]+"")&&ge(t,l),d[0]&4&&a!==(a=s[70])&&k(e,"x",a),d[0]&4&&r!==(r=s[71])&&k(e,"y",r),d[0]&786436&&Qe(e,"chosen",s[19].includes(`${s[18]},${s[69][s[18]]}`))},d(i){i&&_(e),n=!1,o()}}}function Nt(s){let e,l=s[18]in s[69]&&Ot(s);return{c(){l&&l.c(),e=Ve()},l(t){l&&l.l(t),e=Ve()},m(t,a){l&&l.m(t,a),z(t,e,a)},p(t,a){t[18]in t[69]?l?l.p(t,a):(l=Ot(t),l.c(),l.m(e.parentNode,e)):l&&(l.d(1),l=null)},d(t){l&&l.d(t),t&&_(e)}}}function yt(s){let e,l=s[66]+"",t,a,r;function n(){return s[60](s[66])}return{c(){e=P("button"),t=N(l),this.h()},l(o){e=V(o,"BUTTON",{class:!0});var c=j(e);t=y(c,l),c.forEach(_),this.h()},h(){k(e,"class","svelte-1jfuj1x")},m(o,c){z(o,e,c),u(e,t),a||(r=ce(e,"click",n),a=!0)},p(o,c){s=o},d(o){o&&_(e),a=!1,r()}}}function ls(s){let e,l,t,a,r,n,o=s[3].includes(s[10]),c,i=s[3].includes(s[10]),d,w,T,b,p,g,v,D,B,K,ee=(s[23]?"Original":"Modify")+"",te,ve,he,le,se,J,W,q,A,O,C,L,R,_e,G=[],oe=new Map,F,me,He,Ne,We,ye,Be,Me,Q,pe,Le,Ue,tl,we,el,sl,Se=s[3],ne=[];for(let f=0;f<Se.length;f+=1)ne[f]=st(tt(s,Se,f));let Ae=s[4],ae=[];for(let f=0;f<Ae.length;f+=1)ae[f]=ot(lt(s,Ae,f));let ie=o&&nt(s),re=i&&it(s);function ol(f,E){return(w==null||E[0]&3080)&&(w=!!(f[3].includes(f[10])&&f[11])),w?es:((T==null||E[0]&1048640)&&(T=!!f[6].includes(f[20])),T?xt:$t)}let Ge=ol(s,[-1,-1,-1,-1]),be=Ge(s),X=s[21]&&pt(s),Y=s[12]&&jt(s),Fe=s[1];const nl=f=>Ie(f[77]);for(let f=0;f<Fe.length;f+=1){let E=ql(s,Fe,f),m=nl(E);oe.set(m,G[f]=wt(m,E))}let Z=s[12]&&Pt(s),$=s[21]&&!s[23]&&Tt(s),x=s[23]&&Dt(s),h=(s[21]||s[23])&&It(s),U=Object.keys(s[34]),I=[];for(let f=0;f<U.length;f+=1)I[f]=yt(Ul(s,U,f));return{c(){e=P("div"),l=P("div"),t=P("select"),a=P("optgroup");for(let f=0;f<ne.length;f+=1)ne[f].c();r=P("optgroup");for(let f=0;f<ae.length;f+=1)ae[f].c();n=M(),ie&&ie.c(),c=M(),re&&re.c(),d=M(),be.c(),b=M(),p=P("div"),g=P("h3"),v=P("button"),D=N("Plans \u2193"),B=M(),K=P("button"),te=N(ee),ve=M(),X&&X.c(),he=M(),le=P("div"),se=P("h3"),J=P("button"),W=N("Communities \u2193"),q=M(),A=P("button"),O=N("+"),C=M(),Y&&Y.c(),L=M(),R=ke("svg"),_e=ke("g");for(let f=0;f<G.length;f+=1)G[f].c();F=ke("g"),me=ke("path"),Z&&Z.c(),Ne=Ve(),$&&$.c(),We=Ve(),x&&x.c(),ye=Ve(),h&&h.c(),Me=M(),Q=P("div"),pe=P("h3"),Le=N("Views"),Ue=M();for(let f=0;f<I.length;f+=1)I[f].c();this.h()},l(f){e=V(f,"DIV",{class:!0,style:!0});var E=j(e);l=V(E,"DIV",{class:!0});var m=j(l);t=V(m,"SELECT",{style:!0,class:!0});var H=j(t);a=V(H,"OPTGROUP",{label:!0});var Pe=j(a);for(let de=0;de<ne.length;de+=1)ne[de].l(Pe);Pe.forEach(_),r=V(H,"OPTGROUP",{label:!0});var al=j(r);for(let de=0;de<ae.length;de+=1)ae[de].l(al);al.forEach(_),H.forEach(_),n=S(m),ie&&ie.l(m),c=S(m),re&&re.l(m),d=S(m),be.l(m),b=S(m),p=V(m,"DIV",{class:!0});var ze=j(p);g=V(ze,"H3",{class:!0});var il=j(g);v=V(il,"BUTTON",{});var jl=j(v);D=y(jl,"Plans \u2193"),jl.forEach(_),B=S(il),K=V(il,"BUTTON",{class:!0});var kl=j(K);te=y(kl,ee),kl.forEach(_),il.forEach(_),ve=S(ze),X&&X.l(ze),ze.forEach(_),he=S(m),le=V(m,"DIV",{class:!0});var rl=j(le);se=V(rl,"H3",{class:!0});var cl=j(se);J=V(cl,"BUTTON",{});var El=j(J);W=y(El,"Communities \u2193"),El.forEach(_),q=S(cl),A=V(cl,"BUTTON",{});var wl=j(A);O=y(wl,"+"),wl.forEach(_),cl.forEach(_),C=S(rl),Y&&Y.l(rl),rl.forEach(_),m.forEach(_),L=S(E),R=Ee(E,"svg",{viewBox:!0,style:!0,class:!0});var ml=j(R);_e=Ee(ml,"g",{});var Pl=j(_e);for(let de=0;de<G.length;de+=1)G[de].l(Pl);Pl.forEach(_),F=Ee(ml,"g",{class:!0});var Je=j(F);me=Ee(Je,"path",{class:!0,d:!0}),j(me).forEach(_),Z&&Z.l(Je),Ne=Ve(),$&&$.l(Je),We=Ve(),x&&x.l(Je),ye=Ve(),h&&h.l(Je),Je.forEach(_),ml.forEach(_),Me=S(E),Q=V(E,"DIV",{class:!0});var fl=j(Q);pe=V(fl,"H3",{class:!0});var Vl=j(pe);Le=y(Vl,"Views"),Vl.forEach(_),Ue=S(fl);for(let de=0;de<I.length;de+=1)I[de].l(fl);fl.forEach(_),E.forEach(_),this.h()},h(){k(a,"label","Redistricting data"),k(r,"label","American Community Survey data"),je(t,"width",s[4].includes(s[10])?"auto":"calc(var(--control-width) - 20px)"),k(t,"class","svelte-1jfuj1x"),s[10]===void 0&&Oe(()=>s[42].call(t)),k(K,"class","subbutton svelte-1jfuj1x"),k(g,"class","svelte-1jfuj1x"),k(p,"class","stats svelte-1jfuj1x"),k(se,"class","svelte-1jfuj1x"),k(le,"class","stats svelte-1jfuj1x"),k(l,"class","controls svelte-1jfuj1x"),k(me,"class","mesh-bg svelte-1jfuj1x"),k(me,"d",He=s[5].includes(s[20])?s[29]:s[28]),k(F,"class","meshes svelte-1jfuj1x"),k(R,"viewBox",Be=s[16].join(" ")),je(R,"--font-size",s[24]+"px"),k(R,"class","svelte-1jfuj1x"),k(pe,"class","svelte-1jfuj1x"),k(Q,"class","views svelte-1jfuj1x"),k(e,"class","container svelte-1jfuj1x"),je(e,"cursor",s[22]?"crosshair":"auto"),Oe(()=>s[61].call(e))},m(f,E){z(f,e,E),u(e,l),u(l,t),u(t,a);for(let m=0;m<ne.length;m+=1)ne[m].m(a,null);u(t,r);for(let m=0;m<ae.length;m+=1)ae[m].m(r,null);ul(t,s[10]),u(l,n),ie&&ie.m(l,null),u(l,c),re&&re.m(l,null),u(l,d),be.m(l,null),u(l,b),u(l,p),u(p,g),u(g,v),u(v,D),u(g,B),u(g,K),u(K,te),u(p,ve),X&&X.m(p,null),u(l,he),u(l,le),u(le,se),u(se,J),u(J,W),u(se,q),u(se,A),u(A,O),u(le,C),Y&&Y.m(le,null),u(e,L),u(e,R),u(R,_e);for(let m=0;m<G.length;m+=1)G[m].m(_e,null);u(R,F),u(F,me),Z&&Z.m(F,null),u(F,Ne),$&&$.m(F,null),u(F,We),x&&x.m(F,null),u(F,ye),h&&h.m(F,null),u(e,Me),u(e,Q),u(Q,pe),u(pe,Le),u(Q,Ue);for(let m=0;m<I.length;m+=1)I[m].m(Q,null);tl=Ht(e,s[61].bind(e)),we=!0,el||(sl=[ce(t,"change",s[42]),ce(v,"click",s[46]),ce(K,"click",s[47]),ce(J,"click",s[50]),ce(A,"click",s[51]),ce(R,"mousedown",s[58]),ce(R,"mouseup",s[59])],el=!0)},p(f,E){if(E[0]&8){Se=f[3];let m;for(m=0;m<Se.length;m+=1){const H=tt(f,Se,m);ne[m]?ne[m].p(H,E):(ne[m]=st(H),ne[m].c(),ne[m].m(a,null))}for(;m<ne.length;m+=1)ne[m].d(1);ne.length=Se.length}if(E[0]&16){Ae=f[4];let m;for(m=0;m<Ae.length;m+=1){const H=lt(f,Ae,m);ae[m]?ae[m].p(H,E):(ae[m]=ot(H),ae[m].c(),ae[m].m(r,null))}for(;m<ae.length;m+=1)ae[m].d(1);ae.length=Ae.length}if((!we||E[0]&1040)&&je(t,"width",f[4].includes(f[10])?"auto":"calc(var(--control-width) - 20px)"),E[0]&1048&&ul(t,f[10]),E[0]&1032&&(o=f[3].includes(f[10])),o?ie?ie.p(f,E):(ie=nt(f),ie.c(),ie.m(l,c)):ie&&(ie.d(1),ie=null),E[0]&1032&&(i=f[3].includes(f[10])),i?re?re.p(f,E):(re=it(f),re.c(),re.m(l,d)):re&&(re.d(1),re=null),Ge===(Ge=ol(f,E))&&be?be.p(f,E):(be.d(1),be=Ge(f),be&&(be.c(),be.m(l,b))),(!we||E[0]&8388608)&&ee!==(ee=(f[23]?"Original":"Modify")+"")&&ge(te,ee),f[21]?X?(X.p(f,E),E[0]&2097152&&ue(X,1)):(X=pt(f),X.c(),ue(X,1),X.m(p,null)):X&&(Ze(),Te(X,1,1,()=>{X=null}),Xe()),f[12]?Y?(Y.p(f,E),E[0]&4096&&ue(Y,1)):(Y=jt(f),Y.c(),ue(Y,1),Y.m(le,null)):Y&&(Ze(),Te(Y,1,1,()=>{Y=null}),Xe()),E[0]&1087400706|E[1]&1&&(Fe=f[1],G=Wt(G,E,nl,1,f,Fe,oe,_e,Qt,wt,null,ql)),(!we||E[0]&1048608&&He!==(He=f[5].includes(f[20])?f[29]:f[28]))&&k(me,"d",He),f[12]?Z?(Z.p(f,E),E[0]&4096&&ue(Z,1)):(Z=Pt(f),Z.c(),ue(Z,1),Z.m(F,Ne)):Z&&(Ze(),Te(Z,1,1,()=>{Z=null}),Xe()),f[21]&&!f[23]?$?($.p(f,E),E[0]&10485760&&ue($,1)):($=Tt(f),$.c(),ue($,1),$.m(F,We)):$&&(Ze(),Te($,1,1,()=>{$=null}),Xe()),f[23]?x?(x.p(f,E),E[0]&8388608&&ue(x,1)):(x=Dt(f),x.c(),ue(x,1),x.m(F,ye)):x&&(Ze(),Te(x,1,1,()=>{x=null}),Xe()),f[21]||f[23]?h?(h.p(f,E),E[0]&10485760&&ue(h,1)):(h=It(f),h.c(),ue(h,1),h.m(F,null)):h&&(Ze(),Te(h,1,1,()=>{h=null}),Xe()),(!we||E[0]&65536&&Be!==(Be=f[16].join(" ")))&&k(R,"viewBox",Be),(!we||E[0]&16777216)&&je(R,"--font-size",f[24]+"px"),E[0]&65536|E[1]&8){U=Object.keys(f[34]);let m;for(m=0;m<U.length;m+=1){const H=Ul(f,U,m);I[m]?I[m].p(H,E):(I[m]=yt(H),I[m].c(),I[m].m(Q,null))}for(;m<I.length;m+=1)I[m].d(1);I.length=U.length}(!we||E[0]&4194304)&&je(e,"cursor",f[22]?"crosshair":"auto")},i(f){we||(ue(X),ue(Y),ue(Z),ue($),ue(x),ue(h),we=!0)},o(f){Te(X),Te(Y),Te(Z),Te($),Te(x),Te(h),we=!1},d(f){f&&_(e),fe(ne,f),fe(ae,f),ie&&ie.d(),re&&re.d(),be.d(),X&&X.d(),Y&&Y.d();for(let E=0;E<G.length;E+=1)G[E].d();Z&&Z.d(),$&&$.d(),x&&x.d(),h&&h.d(),fe(I,f),tl(),el=!1,Ml(sl)}}}async function ts(s){const l=await(await s("/points.topojson")).json();return Nl(l,l.objects.layer).features}async function is({fetch:s}){const l=await(await s("/output.topojson")).json(),t=Xt(l.objects.census),a=Nl(l,t).features,r=["cvap","pop"],n=[...a.reduce((w,T)=>{const b=Object.keys(T.properties).filter(p=>[...r,"GEOID","senate","assembly","congress"].every(g=>!p.includes(g))&&p===p.toLowerCase()).map(p=>p.split("_")[0]);return new Set([...w,...b])},[])],o=a.reduce((w,T,b)=>(w[T.properties.GEOID]=b,w),{}),c=Lt(),i={},d=w=>Object.values(w.properties)[0];return Object.keys(l.objects).forEach(w=>{w!=="census"&&(i[w]=c(yl(l,l.objects[w],(T,b)=>d(T)!==d(b))))}),{props:{topoData:l,obj:t,data:a,neighbors:Ut(t.geometries),dynamicVars:r,staticVars:n,idToIndex:o,points:await ts(s),path:c,plansMeshes:i,tractVars:["asiaentry","workers"],pluralityVars:["asiaentry"]}}}function ss(s,e,l){let t,a,r,n,{topoData:o,obj:c,neighbors:i,data:d,points:w,dynamicVars:T,staticVars:b,tractVars:p,pluralityVars:g,plansMeshes:v,path:D,idToIndex:B}=e;const K=h=>yl(o,c,h),ee=D(K((h,U)=>Ie(h)!==Ie(U))),te=D(K((h,U)=>Ie(h).substring(0,11)!==Ie(U).substring(0,11))),ve=h=>d[h].properties[Q];let he;function le(h){const U=ve(h),I=new Set(i[h].map(ve).filter(f=>f!==U));if(I.size===1){const f=I.values().next().value;l(0,c.geometries[h].properties[Q]=f,c),l(0,c),he=f}else I.has(he)&&(l(0,c.geometries[h].properties[Q]=he,c),l(0,c))}let se="present",J="pop";const W={pop:[0,.1,.2,.4,.6],cvap:[0,.1,.2,.4,.6]};let q=!1;function A({properties:h}){if(h.ALAND===0)return"#fff";const U=h[`${t}_total`];if(g.includes(t)){const I=E=>h[`${t}_${E}`];if(I(qe[0])===null)return"#eee";const f=[...qe].sort((E,m)=>I(m)-I(E));return xe[qe.indexOf(f[0])]}else if(b.includes(t)){if(!h.ALAND)return"#fff";if(!Ll(a(h)))return"#eee";if(U<=10)return"#fff";for(let I=1;I<r.length;I++)if(a(h)<r[I])return xe[I];return xe[r.length-1]}else{if(U<=10)return"#fff";const I=f=>h[`${t}_${f}`]/h[`${t}_total`];if(q){const f=Re.filter(H=>I(H)>.5)[0];if(f!==void 0)return bl[f]+pl[U<130?0:U<200?1:2];const E=[...Re].sort((H,Pe)=>I(Pe)-I(H)),m=I(E[0])-I(E[1]);return bl[E[0]]+pl[m<.093?0:1]}else{const f=W[J];for(let E=1;E<f.length;E++)if(I("asian")<f[E])return gl[E-1];return gl[f.length-1]}}}let O,C,L,R,_e,G=[],oe=[];function F(h){let U;typeof h[0]=="string"?U=h.map(H=>d[B[H]].properties):U=h.map(H=>H.properties);const I=(H,Pe)=>U.reduce((al,ze)=>al+(ze[H]||0)*(Pe&&ze[Pe]||1),0),f=H=>I(H,"pop20_total")/I("pop20_total"),E=(H,Pe)=>I(`${H}_${Pe}`)/I(`${H}_total`),m={income:f("income"),hhlang:E("hhlang","asian"),benefits:E("families","benefits"),pop20_total:I("pop20_total")};return["pop20","cvap19"].forEach(H=>Re.forEach(Pe=>m[H+Pe]=E(H,Pe))),console.log(m,U[0]),m}const me=h=>l(15,oe=oe.filter((U,I)=>I!==h));async function He(){await fetch("/data.json",{method:"POST",body:JSON.stringify(oe)})}let Ne;async function We(){const h=await fetch("/data.json");l(15,oe=(await h.json()).map(U=>Ol(Il({},U),{stats:F(U.ids)})))}const ye={Manhattan:[80,430,500,440],Brooklyn:[20,550,600,600],Full:[0,0,975,1420]};let Be=ye.Manhattan,Me,Q="assembly",pe=[],Le={};function Ue(h){pe.includes(h)?l(19,pe=pe.filter(U=>U!==h)):l(19,pe=[...pe,h])}const tl=[[]];function we(){J=Sl(this),l(10,J),l(4,b),l(3,T)}function el(){se=this.__value,l(9,se)}const sl=()=>l(11,q=!q),Se=()=>{l(21,O=!O),l(12,C=!1)},ne=()=>l(23,_e=!_e);function Ae(){Q=Sl(this),l(18,Q)}const ae=h=>Ue(h),ie=()=>{l(12,C=!C),l(21,O=!1)},re=()=>l(22,L=!0),ol=h=>me(h),Ge=h=>_e&&le(h),be=h=>console.log(h.properties),X=h=>L&&R&&(G.length===0?l(14,G=[Ie(h)]):G.push(Ie(h))),Y=(h,U)=>h.properties[Q]!==U.properties[Q],Fe=h=>Ue(`${Q},${h[Q]}`),nl=()=>l(13,R=!0),Z=()=>l(13,R=l(22,L=!1)),$=h=>l(16,Be=ye[h]);function x(){Me=this.clientWidth,l(17,Me)}return s.$$set=h=>{"topoData"in h&&l(36,o=h.topoData),"obj"in h&&l(0,c=h.obj),"neighbors"in h&&l(37,i=h.neighbors),"data"in h&&l(1,d=h.data),"points"in h&&l(2,w=h.points),"dynamicVars"in h&&l(3,T=h.dynamicVars),"staticVars"in h&&l(4,b=h.staticVars),"tractVars"in h&&l(5,p=h.tractVars),"pluralityVars"in h&&l(6,g=h.pluralityVars),"plansMeshes"in h&&l(7,v=h.plansMeshes),"path"in h&&l(8,D=h.path),"idToIndex"in h&&l(38,B=h.idToIndex)},s.$$.update=()=>{if(s.$$.dirty[0]&1552&&l(20,t=b.includes(J)?J:J+(se==="past"?10:J==="cvap"?19:20)),s.$$.dirty[0]&1048576&&l(41,a={income:h=>h[t],hhlang:h=>h[`${t}_asian`]/h[`${t}_total`],graduates:h=>(h[`${t}_hs_grad`]+h[`${t}_ba_above`])/h[`${t}_total`],families:h=>h[`${t}_benefits`]/h[`${t}_total`],workers:h=>h[`${t}_publictransport`]/h[`${t}_total`]}[t]),s.$$.dirty[0]&1051674|s.$$.dirty[1]&1280&&l(25,r=T.includes(J)&&!q?W[J]:W[t]||!b.includes(t)||t==="asiaentry"||l(39,W[t]=Gt(d.map(h=>a(h.properties)).filter(Ll),6),W)),s.$$.dirty[0]&57602&&!R&&G.length>0){if(G[0]===G[G.length-1]){const h=new Set(G),U=Ft(K((f,E)=>Yt(h.has(Ie(f)),h.has(Ie(E)))).coordinates.flat()),I=d.map(f=>[Jt(Kt(f.geometry.coordinates[0]),U),Ie(f)]).filter(f=>f[0]).map(f=>f[1]);l(15,oe=[...oe,{outline:D({type:"LineString",coordinates:U}),ids:I,stats:F(I)}])}l(14,G=[])}if(s.$$.dirty[0]&4096|s.$$.dirty[1]&512&&C&&!Ne&&(We(),l(40,Ne=!0)),s.$$.dirty[0]&458752&&l(24,n=(Q.endsWith("_names")?13:16)/((Me-410)/Be[2])),s.$$.dirty[0]&786433)for(let h=0;h<pe.length;h++){const[U,I]=pe[h].split(",");U===Q&&l(26,Le[pe[h]]=F(c.geometries.filter(({properties:f})=>I===""+f[Q])),Le)}},[c,d,w,T,b,p,g,v,D,se,J,q,C,R,G,oe,Be,Me,Q,pe,t,O,L,_e,n,r,Le,K,ee,te,le,A,me,He,ye,Ue,o,i,B,W,Ne,a,we,el,tl,sl,Se,ne,Ae,ae,ie,re,ol,Ge,be,X,Y,Fe,nl,Z,$,x]}class rs extends zt{constructor(e){super();Rt(this,e,ss,ls,qt,{topoData:36,obj:0,neighbors:37,data:1,points:2,dynamicVars:3,staticVars:4,tractVars:5,pluralityVars:6,plansMeshes:7,path:8,idToIndex:38},null,[-1,-1,-1,-1])}}export{rs as default,is as load};
