function [nao_re,nao_trnc,nao_seas,nao_neg,nao_pos] = prepareNAOs(naodat,varargin)
% [nao_re,nao_trnc,nao_seas,nao_neg,nao_pos] = prepareNAOs(naodat,varargin)
%
% preparation of NAO-timeseries before comparison
%
% NECESSARY INPUT (in this order):
%   - naodat: string of filename (e.g. 'nao_1.data')
% POSSIBLE INPUT:
%   - reshape:  true or false / 1 or 0 (logical)
%   - replace:  values to be replaced by NaN (double)
%   - truncate: year from which on to take the data (double)
%   - extract:  3 months (vector e.g. [12 1 2] for december, january, february)
%   - extract:  Pos/Neg NAO: true or false + following option
%   - extractOption:
%       o   true: extract Pos/Neg NAO from the monthly extracted data.
%       o   false: extract Pos/Neg NAO from any other available data.
%
% CAUTION.
%   keep care of the order in which things get done.
%       o truncate uses the already reshaped and replaced values, except
%       this option was not chosen, then it takes the original data
%       o extractMonths tries at first the truncated data, then the
%       reshaped data, then the original data
%       o extractPosNeg tries at first the truncated data, then the
%       reshaped data, then the original data.

addpath(genpath(cd), genpath(['..' filesep 'data' filesep 'nao']));

nao_orig = load(naodat);

% reshape
if varargin{1} == true
    nao_re = reshapeNAO(nao_orig);
end

% replace values
if isempty(varargin{2}) ~= 1
    nao_re.nao(nao_re.nao == varargin{2}) = NaN;
end

% truncate
if isempty(varargin{3}) ~= 1
    if exist('nao_re','var') == 1
        nao = nao_re;
    else
        nao = nao_orig.nao;
    end
    date = datetime(varargin{3},1,1);
    nao_trnc = struct('time',nao.time(nao.time >= date,:));
    nao_trnc = setfield(nao_trnc,'nao',nao.nao(nao.time >= date,:));
end
clear nao

% extract months
if isempty(varargin{4}) ~= 1
    if exist('nao_trnc','var') == 1
        nao = nao_trnc;
    elseif exist('nao_re','var') == 1
        nao = nao_re;
    else
        nao = nao_orig.nao;
    end
    idx = month(nao.time) == varargin{4}(1) | month(nao.time) == varargin{4}(2) | month(nao.time) == varargin{4}(3);
    % + convert timestamps to datetime format
    nao_seas = struct('time', nao.time(idx));
    nao_seas = setfield(nao_seas, 'nao',nao.nao(idx));
end
clear nao

% extrPosNeg
if varargin{5} == true
    if varargin{6} == 1
        nao = nao_seas;
    elseif exist('nao_trnc','var') == 1
        nao = nao_trnc;
    elseif exist ('nao_re','var') == 1
        nao = nao_re;
    else
        nao = nao_orig.nao;
    end
    nao_neg = struct('time',nao.time(nao.nao <= 0));
    nao_neg.nao_neg = nao.nao(nao.nao <= 0);
    nao_pos = struct('time',nao.time(nao.nao > 0));
    nao_pos.nao_pos = nao.nao(nao.nao > 0);
end

% fake-outputs
if exist('nao_re','var') == 0
    nao_re = [];
end
if exist('nao_trnc','var') == 0
    nao_trnc = [];
end
if exist('nao_seas','var') == 0
    nao_seas = [];
end
if exist('nao_negpos','var') == 0
    nao_negpos = [];
end

end