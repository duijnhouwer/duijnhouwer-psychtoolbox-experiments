function [s, sFull, str] = pfit(varargin)
% PFIT    fitting, bootstrapping, goodness-of-fit and sensitivity analysis
% 
%   PFIT(DAT [, plot option][, fitting options...])
%   
%   S = PFIT(DAT) fits a psychometric function to the data DAT and performs
%   1999 bootstrap simulations in order to estimate the variability of fitted
%   parameters and estimated thresholds and slopes. The procedure then performs
%   a "sensitivity analysis": based on the distribution of parameters alpha and
%   beta, the whole processes is repeated at a number of different locations
%   in parameter space, in order to determine how sensitive the variability
%   estimates would be to inaccuracy of the initial fit.
%   
%   PFIT calls the PSIGNIFIT engine to fit and perform simulations. All fitting
%   options take their normal default values unless additional arguments are
%   supplied (type HELP PSYCH_OPTIONS for an explanation of the available options
%   and their defaults).  Fitting options can be passed in through PFIT, which
%   runs them through BATCH before passing them on to the engine. Thus, for
%   example:
%           PFIT(DAT, 'shape', 'w', 'n_intervals', 1, 'runs', 4999)
%   might be used in order to specify the Weibull function in a yes/no task,
%   with 4999 bootstrap runs instead of the default 1999. To suppress text output
%   set the 'verbose' option to 0 or 'false'.
%            NB:   the "#WRITE_..." engine options will not work with PFIT, and
%   should not be used. PFIT is an m-file "wrapper" for the PSIGNIFIT engine, and
%   uses these options itself in order to obtain output in a certain format. 
% 
%   PFIT also calls PSYCHOSTATS for a statistical analysis of goodness-of-fit.
%   This may be disabled by setting the fitting option 'compute_stats' to 0 or
%   'false'.
%   
%   All other psignifit engine options are supported (see PSYCH_OPTIONS for
%   details. Of particular interest are the following):
% 
%       CUTS:  the levels at which thresholds and slopes are calculated
%              default is [0.2 0.5 0.8], which would, in the 2AFC paradigm
%              which is the default, correspond roughly to 60%, 75% and 90%
%              correct.
%           
%       CONF:  the cumulative probability values at which confidence interval
%              boundaries are calculated. The default setting is
%              [0.023 0.159 0.841 0.977]. If all distributions were Gaussian,
%              then this would correspond to [-2, -1, +1, +2] standard
%              deviations from the mean. If the CONF vector has 2 or 4 elements,
%              then error bars can be plotted from the results using the
%              function PSYCHERRBAR.
%           
%       SENS:  The number of points taken in the sensitivity analysis.
%   
%       SENS_COVERAGE:
%              the "coverage" of the sensitivity analysis, which determines
%              how far the sensitivity procedure moves when exploring parameter
%              space.  Points are chosen on the skin of a joint confidence region of 
%              coverage SENS_COVERAGE in parameter space. The shape of the region
%              is likelihood-based  (all points on the skin have the same deviance value 
%              with respect to the original data set). The points' precise locations are
%              chosen by an algorithm that uses the original bootstrap distribution of
%              parameters, and aims to spread out the points' directions in the alpha/beta
%              plane while exploring the extremes of variation in alpha and beta within the
%              region (gamma and lambda, if they are free parameters, may be varied in
%              order to accomplish this aim).
% 
%   By default, if an output argument is requested, there is no graphical output.
%   If no output is requested, the procedure returns one anyway, and also plots
%   its results, including the plots generated by PSYCHOSTATS. Graphical output
%   can be controlled explicitly using an optional plot specifier: 
%           PFIT(DAT, PLOT_OPT, .....)
%   where PLOT_OPT is one of the following:
%               'plot', 'no plot' or 'plot without stats'.
%   The last of these allows the data and fitted function to be plotted, but
%   suppresses graphical output from PSYCHOSTATS.
%   (NB: PLOT_OPT has to be the first string argument, and is treated separately from
%   the other options. This made it slightly awkward to write wrappers. The awkward
%   way will still work, for reasons of backward compatibility. However, as of version
%   2.5.41, it is also possible to pass the PLOT_OPT string among the regular options,
%   under the dummy identifier 'PLOT_OPT'.)
%   
%   The output S is a structure with the following fields:
%       shape:          The shape of the function used for fitting (see PSYCHF).
%       params:         A structure (see below)
%       stats:          The output structure from PSYCHOSTATS
%       cuts:           The levels on the curve at which thresholds and slopes
%                       were evaluated (as per the input argument CUTS, above)
%       conf:           As per the input argument CONF, above
%       slopes:         A structure (see below)
%       thresholds:     A structure (see below)
%       confLimMethod:  The method used to estimate confidence limits from
%                       bootstrap distributions: Either 'percentile' or 'BCa',
%                       to indicate which bootstrap method's results are reported
%                       in the 'lims' field (and which method is iterated for the
%                       expanded method and reported in the 'worst' field).
%       sens:           A structure giving details of the sensitivity analysis,
%                       including a record of which points in parameter-space
%                       were chosen.
%       gen:            Generating probabilities for each point in simulated
%                       data sets, predicted by the fitted function (usually)
%                       or specified by the user in the fitting options.
%       R:              The number of runs in the bootstrap simulation.
%       randSeed:       The random seed used for simulation in PSIGNIFIT.
%   
%   The 'params' struct contains matrices in which the first column refers to
%   the alpha parameter, the second to beta, the third to gamma and the fourth to
%   lambda. The 'thresholds' and 'slopes' structs contain matrices in which the
%   columns represent the different cuts, in increasing order. The 'params',
%   'thresholds' and 'slopes' structures contain the following fields. 
%       est:    The estimated values, from the original fit, or from the distribution
%               specified by the user.
%       lff:    Currently empty, and reserved for future use in BCa calculations.
%               Each of its four rows will denote a component of the least-favourable
%               direction for the measure in question, in the direction of one of the
%               four parameters.
%       lims:   Confidence limits for the measures in question. Each row denotes
%               a different confidence limit, corresponding to the elements of S.conf.
%               The confidence levels will have been sorted in increasing order.
%       worst:  Similar to lims, except that these limits represent the "worst case"
%               encountered during sensitivity analysis. For each element x of this
%               matrix, the difference between x and the corresponding maximum-
%               likelihood estimate is the same as the largest such difference
%               encountered in the SENS+1 bootstrap runs. Thus the limits in
%               'worst', when compared with the limits in 'lims', demonstrate the
%               magnitude of the effect of variations in the generating parameters
%               on the width of confidence intervals.
% 
%   In the graphical output, error bars the same colour as the data-points
%   indicate the bootstrap confidence limits for the thresholds, as recorded
%   in S.thresholds.lims, and the fainter bars slightly below them indicate the
%   "worst case" confidence limits, S.thresholds.worst.
% 
%   An optional second output argument, S_FULL, is similar to S, but contains
%   additional information such as the full distributions of bootstrap values.
%     
%   See also PSIGNIFIT, PSYCHOSTATS, PSYCHERRBAR
    
% Part of the psignifit toolbox version 2.5.6 for MATLAB version 5 and up.
% Copyright (c) J.Hill 1999-2005.
% Please read the LICENSE and NO WARRANTY statement in psych_legal.m
% mailto:psignifit@bootstrap-software.org
% http://bootstrap-software.org/psignifit/

defaultOpts = {
	'runs'			1999
}';

dat = []; plotOpt = ''; i = 1;
plotOpts = {'no plot', 'plot', 'plot without stats', 'plot with polyfits', 'plot without polyfits'};
while ~isempty(varargin)
	arg = varargin{1};
	if isnumeric(arg) & isempty(dat) & ismember(size(arg, 2), [3 4])
		dat = double(arg(:, end-2:end));
	elseif ~isempty(arg) & ~isstr(arg) | size(arg, 1) > 1
		error(sprintf('could not interpret argument %d as a data set or option string', i))
	elseif ~isempty(arg)
		matchPlotOpt = min(strmatch(lower(arg), plotOpts));
		if isempty(matchPlotOpt), break; end
		plotOpt = plotOpts{matchPlotOpt};
	end
	varargin(1) = []; i = i + 1;
end

opts = {};
for i = 1:length(varargin)
	arg = varargin{i};
	if isstr(arg) & any(arg == '#')
		lasterr(''), eval('batchStringContent = batch2struct(arg); ', ''); error(lasterr)
		if isempty(batchStringContent), batchStringContent = {};
		else batchStringContent = [fieldnames(batchStringContent)';struct2cell(batchStringContent)'];
		end
		opts = [opts batchStringContent(:)'];
	else
		opts{end + 1} = arg;
	end
end
lasterr(''), eval('opts = batch(defaultOpts{:}, opts{:}); ', ''); error(lasterr)

if isempty(plotOpt) % make the 'plot' business slightly more useable - add a false option #PLOT_OPT
	plotOpt = batch(opts, 'plot_opt');
	if ~isempty(plotOpt)
		if isnumeric(plotOpt) | islogical(plotOpt)
			switch double(plotOpt)
			case 0, plotOpt = plotOpts{1};
			case 1, plotOpt = plotOpts{2};
			otherwise, plotOpt = plotOpts{3};
			end
		end
		plotOpt = min(strmatch(lower(plotOpt), plotOpts));
		if isempty(plotOpt)
			plotOpts(2, :) = {'\n\t'};
			error(sprintf('unrecognized PLOTOPT input -- supported values are:\n\t%s', [plotOpts{1:end-1}]))	
		end
		plotOpt = plotOpts{plotOpt};
		opts = batch(opts, 'plot_opt', []);
	end
end
if isempty(plotOpt), plotOpt = plotOpts{double((nargout == 0) + 1)}; end
if strcmp(lower(plotOpt), 'plot without stats'), statsPlotOpt = 'no plot'; else statsPlotOpt = plotOpt; end
doFitPlot = ~strcmp(lower(plotOpt), 'no plot');

% we will need to know what some of the batch options are
os = batch2struct(opts);
mOpts.shape = psychf(GetOption(os, 'shape', 'logistic'));
mOpts.nIntervals = GetOption(os, 'n_intervals', 2);
mOpts.verbose = GetOption(os, 'verbose', 1);
mOpts.R = GetOption(os, 'runs', 0);
mOpts.genShape = psychf(GetOption(os, 'gen_shape', mOpts.shape));
mOpts.genParams = GetOption(os, 'gen_params', []);
mOpts.genValues = GetOption(os, 'gen_values', []);
mOpts.refit = GetOption(os, 'refit', (mOpts.R>0 & isempty(mOpts.genValues) & isempty(mOpts.genParams) & strcmp(mOpts.shape, mOpts.genShape) & GetOption(os, 'compute_params', 1)));
[mOpts.slopeOpt mOpts.cutOpt] = findslope('options', [], [], ...
	GetOption(os, 'slope_opt', 'linear x'), GetOption(os, 'cut_opt', 'underlying'));
defaultCuts = [0.2 0.5 0.8];
if strcmp(lower(mOpts.cutOpt), 'performance'),
	defaultCuts = defaultCuts * (1 - 1 / mOpts.nIntervals) + 1 / mOpts.nIntervals;
end
mOpts.cuts = GetOption(os, 'cuts', defaultCuts); mOpts.cuts = sort(mOpts.cuts(:)');
if length(mOpts.cuts) == 1, if isnan(mOpts.cuts), mOpts.cuts = []; end, end
mOpts.conf = GetOption(os, 'conf', [0.023 0.159 0.841 0.977]); mOpts.conf = sort(mOpts.conf(:)');
if length(mOpts.conf) == 1, if isnan(mOpts.conf), mOpts.conf = []; end, end
mOpts.sensCoverage = GetOption(os, 'sens_coverage', 0.5); %0.683);
if any(mOpts.sensCoverage(:) > 1) mOpts.sensCoverage  = mOpts.sensCoverage / 100; end
mOpts.sensNPoints = GetOption(os, 'sens', 8);

if ~isempty(strmatch('write_', fieldnames(os))), error('write_... options cannot be used in PFIT'), end

% Initial fit & bootstrap
[s rSeed err] = Core(dat, opts, mOpts); error(err)

% Only do sensitivity analysis if simulations were performed, and an
% initial estimated parameter set was returned. So, no analysis will be
% performed if the shape of the generating function is different from the
% shape of the fitting function, or if #GEN_VALUES was used.
doSens = (~isempty(s.params.est) & size(s.params.sim, 1) > 98 & mOpts.sensNPoints > 0 & mOpts.sensCoverage > 0);

% Stats analysis using PSYCHOSTATS
[x y] = parsedataset(dat);
if isempty(mOpts.genParams) & strcmp(lower(mOpts.shape), lower(mOpts.genShape)), mOpts.genParams = s.params.est; end
if isempty(mOpts.genValues) & ~isempty(mOpts.genParams)
	mOpts.genValues = psi(mOpts.genShape, mOpts.genParams, x(:)');
end
figHandle = []; h = {[], [], [], [], []};
if ~isempty(mOpts.genValues) & ~isempty(s.stats.sim)
	sfp = zeros(double(~mOpts.refit));
	lasterr(''), eval('[s.stats.analysis figHandle] = psychostats(dat, mOpts.genValues, [], s.stats.est, s.stats.sim, sfp, statsPlotOpt); ', ''); error(lasterr)
end
% Plot psychometric function
if ~isempty(mOpts.genParams) & doFitPlot
	if ~isempty(figHandle)
		subplot(2, 3, 1)
		ans = setdiff(get(gcf, 'children'), gca); set(gcf, 'children', [gca; ans(:)])
		if ~strcmp(lower(get(gca, 'tag')), 'psychoplot'), cla, grid off, hold off, end
	end
	if strcmp(lower(get(gca, 'buttondownfcn')), 'clickplots(-gca)'), clickplots(-gca), end
	h = psychoplot(dat, s, {mOpts.genShape, mOpts.genParams});
	set(gca,'fontweight', 'bold')

	delete(findobj(gca, 'tag', 'pfit_rmtext'))
	if mOpts.R > 0
		h{5} = text(max(xlim)-diff(xlim)/30, min(ylim)+diff(ylim)/2, sprintf('R = %d', mOpts.R));
		set(h{5}, 'horizontalAlignment', 'right', 'verticalAlignment', 'middle', 'fontsize', get(gca, 'defaulttextfontsize')-1, 'color', get(h{2}(1), 'color'), 'tag', 'pfit_rmtext')
		if ~isempty(x), if mean(x) > mean(xlim), ans = get(h{5}, 'position'); ans(1) = min(xlim)+diff(xlim)/30; set(h{5}, 'horizontalAlignment', 'left', 'position', ans); end, end
	end
	xlabel('stimulus'), ylabel('performance')
		
	figure(gcf)	
end
drawnow

% Sensitivity analysis
if doSens & ~isempty(s.sens.params)
	s.sens.coverage = mOpts.sensCoverage;
	s.sens.nPoints = size(s.sens.params, 1);
	s.sens.inside = logical(s.sens.inside);
	sens = s.sens;
	if doFitPlot
		sensFig = figure('numbertitle', 'off', 'name', 'sensitivity analysis', 'units', 'normalized', 'position', [0.45 0.05 0.5 0.5]);
		sensHandle = sensplot(s.params.est, s.params.sim, sens.params, s.params.lims, sens.inside);
		sensHandle = copyobj(sensHandle{2}, gca);
		set(sensHandle, 'xdata', nan, 'ydata', nan, 'markerfacecolor', [0 1 0.5], 'markersize', get(sensHandle, 'markersize')+4)
		set(gca, 'drawmode', 'fast')
	end	
 	if doFitPlot, bannerFig = gcf; figSetting1 = get(bannerFig, 'numbertitle'); figSetting2 = get(bannerFig, 'name'); end
	if mOpts.verbose, disp(sprintf('running sensitivity analysis (%d points)', sens.nPoints)), end
	tic
	sensOpts = batch(opts, 'verbose', 0, 'sens', 0, 'refit', 0); 
	mSensOpts = mOpts;
	mSensOpts.genShape = mSensOpts.shape;
	mSensOpts.genValues = [];
	mSensOpts.verbose = 0;
	mSensOpts.refit = 0;
	for i = 1:sens.nPoints
		if doFitPlot
			set(bannerFig, 'numbertitle', 'off', 'name', sprintf('sensitivity analysis: running #%d of %d', i, sens.nPoints))
			set(sensHandle, 'xdata', sens.params(i, 1), 'ydata', sens.params(i, 2)), drawnow
		elseif mOpts.verbose
			disp(sprintf('\trun #%d of %d', i, sens.nPoints));
		end
		sensOpts = batch(sensOpts, 'gen_params', sens.params(i, :), 'random_seed', rSeed+i);
		mSensOpts.genParams = sens.params(i, :);
		[ss ans err] = Core(dat, sensOpts, mSensOpts); error(err)
		s(i+1) = ss; 
		if ~isempty(ss.stats.cpe) s(1).sens.stats_cpe(i, :) = ss.stats.cpe; end
	end
	if mOpts.verbose, disp(sprintf('%.2g seconds', toc)), disp(' '), end
	if doFitPlot, set(bannerFig, 'numbertitle', figSetting1, 'name', figSetting2), end
	if doFitPlot, delete(sensFig), end
	s(1).params.worst = WorstCaseLims([s.params]);
	s(1).slopes.worst = WorstCaseLims([s.slopes]);
	s(1).thresholds.worst = WorstCaseLims([s.thresholds]);
	s = s(1);
else
	s.sens = [];
	s.params.worst = [];
	s.slopes.worst = [];
	s.thresholds.worst = [];
end

% Plot "worst case" error bars
if ~isempty(h{3}) & ~isempty(s.thresholds.worst)
	axes(get(h{3}(1), 'parent'))
	delete(cat(1, h{1:4})), washeld = ishold; hold on
	h(1:4) = psychoplot(dat, s, {mOpts.genShape, mOpts.genParams});
	if ~isempty(h{5}), ans = get(h{5}, 'string'); set(h{5}, 'string', sprintf('%s\nm = %d', ans, s.sens.nPoints)), end
	if ~washeld, hold off, end, figure(gcf), drawnow
end

s.gen = mOpts.genValues(:)';
s.R = mOpts.R;
s.randSeed = rSeed;
s.options = opts;

sFull = s;
s = rmfield(s, 'options');
s = rmfield(s, 'ldot');
s.params = rmfield(s.params, 'sim');
if isfield(s.params, 't1'), s.params = rmfield(s.params, 't1'); end
if isfield(s.params, 't2'), s.params = rmfield(s.params, 't2'); end
s.thresholds = rmfield(s.thresholds, 'sim');
if isfield(s.thresholds, 't1'), s.thresholds = rmfield(s.thresholds, 't1'); end
if isfield(s.thresholds, 't2'), s.thresholds = rmfield(s.thresholds, 't2'); end
s.slopes = rmfield(s.slopes, 'sim');
if isfield(s.slopes, 't1'), s.slopes = rmfield(s.slopes, 't1'); end
if isfield(s.slopes, 't2'), s.slopes = rmfield(s.slopes, 't2'); end
if isstruct(s.sens), if isfield(s.sens, 'inside'), s.sens = rmfield(s.sens, 'inside'); end, end
if isfield(s.stats, 'analysis'), s.stats = s.stats.analysis; else s.stats = s.stats.est; end

str = psychreport(s);
if mOpts.verbose, disp(str), end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [s, rSeed, err] = Core(dat, prefs, mOpts)
% perform fits and simulations, find confidence limits

s.shape = mOpts.shape;
rSeed = []; err = [];
lasterr('')

% If warnings are on, make sure they occur every time (pre-R13 issue only),
% and neutralize the 'backtrace' option: (people can understand single-line
% warnings, but tend to panic and turn blue (and e-mail me) when they see the
% whole back-trace for each warning).
warnState = getwarnstate;
if postr13
	warning off backtrace
	warning off verbose
else
	if ~strcmp(lower(warnState.state), 'off'), warning on, warning always, end
end

outputPrefs = {
	'write_pa'			's.params'
	'write_st'			's.stats'
	'write_th'			's.thresholds'
	'write_sl'			's.slopes'
	'write_ldot'		's.ldot'
	'write_fisher'		's.fisher'
	'write_random_seed'	'rSeed'
	'write_sens_params'	's.sens.params'
	'write_in_region'	's.sens.inside'
}';

prefs = batch(prefs, outputPrefs{:});
if isempty(dat), engineArgs = {prefs}; else engineArgs = {dat, prefs}; end

lasterr('')
eval('psignifit(engineArgs{:});', '');
err = lasterr; lasterr('')
if isempty(err) & ~isfield(s, 'params')
	err = 'aborted by user'; 
elseif isempty(err)
	s.cuts = mOpts.cuts(:)';
	s.conf = mOpts.conf(:)';
	s.slopes.wrt = mOpts.slopeOpt;	
	if isempty(s.params.lims) | isempty(s.thresholds.lims) | isempty(s.slopes.lims)
		s.params.lims = s.params.quant;
		s.thresholds.lims = s.thresholds.quant;
		s.slopes.lims = s.slopes.quant;
		s.confLimMethod = 'percentile'; 
	else
		s.confLimMethod = 'BCa'; 
	end
end
setwarnstate(warnState)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function opt = GetOption(b, name, default)

if isfield(b, name)
	lasterr('')
	opt = eval('getfield(b, name)', '[]');
	lasterr('')
else
	opt = [];
end
if isstr(opt)
	if strcmp(lower(opt), 'true'), opt = 1; end
	if strcmp(lower(opt), 'false'), opt = 0; end
end
if isempty(opt), opt = default; end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function lims = WorstCaseLims(s)

lims = cat(3, s.lims);
est = repmat(cat(3, s.est), [size(lims, 1) 1 1]);
lims = lims - est;

mins = min(lims, [], 3);
maxes = max(lims, [], 3);

lhs = find(lims(:, :, 1) < 0);
lims = maxes;
lims(lhs) = mins(lhs);

lims = lims + est(:, :, 1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%