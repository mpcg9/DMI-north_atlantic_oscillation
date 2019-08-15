function nao = prepareNAOs(naodat,reshape,rep99,extrWinter,extrPosNeg,trnc)
% INPUT:
%   - naodat: string of filename (e.g. 'nao_1.data')
%   - reshape: true or false
%   - rep99: true or false
%   - extrWinter: true or false
%   - extrPosNeg: true or false
%   - trnc: true or false
%

if nargin < 1
    naodat = 'nao_1.data';
    reshape = true;
    rep99 = false;
    extrWinter = true;
    extrPosNeg = false;
    trnc = true;
end

addpath(genpath(cd), genpath(['..' filesep 'data' filesep 'nao']));

nao_orig = load(naodat);

if reshape == true
    nao_re = reshapeNAO(nao_orig);
end

if rep99 == true
    nao_re(nao_re == -99.99) = NaN;
end

if trnc == true
    nao_trnc = nao_re(nao_re(:,1) >= 2000,:);
end

if extrWinter == true
   idx = nao_re(:,2) == 12 | nao_re(:,2) == 1 | nao_re(:,2) == 2;
   nao_wi = struct('time', datetime(nao_re(idx,1),nao_re(idx,2),1,'Format','dd.MM.yyyy'));
   nao_wi = setfield(nao_wi, 'nao',nao_re(idx,3));
end

if extrPosNeg == true
   nao_neg = nao_1_wi.time(nao_1_winter.nao <= 0);
   nao_pos = nao_1_wi.time(nao_1_winter.nao > 0); 
end

end