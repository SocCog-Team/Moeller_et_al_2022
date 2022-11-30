function [ ] = fnFormatDefaultAxes( type )
%FNFORMATDEFAULTAXES Set default font and fontsize and line width for all
%axes
%FORMAT_DEFAULT format the plots for further processing...
%   type is simple a unique string to select the requested set
% 20070827sm: changed default output formatting to allow pretty paper output
switch type
    case 'PNM2019'
        set(0, 'DefaultAxesLineWidth', 0.5, 'DefaultAxesFontName', 'Arial', 'DefaultAxesFontSize', 12, 'DefaultAxesFontWeight', 'normal');
    case 'BoS_manuscript'
        set(0, 'DefaultAxesLineWidth', 0.5, 'DefaultAxesFontName', 'Arial', 'DefaultAxesFontSize', 7, 'DefaultAxesFontWeight', 'normal');
    case 'SfN2018'
        set(0, 'DefaultAxesLineWidth', 0.5, 'DefaultAxesFontName', 'Arial', 'DefaultAxesFontSize', 6, 'DefaultAxesFontWeight', 'normal');
    case 'PrimateNeurobiology2018DPZ'
        set(0, 'DefaultAxesLineWidth', 2.0, 'DefaultAxesFontName', 'Arial', 'DefaultAxesFontSize', 20, 'DefaultAxesFontWeight', 'bold');
    case 'DPZ2017Evaluation'
        set(0, 'DefaultAxesLineWidth', 2.0, 'DefaultAxesFontName', 'Arial', 'DefaultAxesFontSize', 20, 'DefaultAxesFontWeight', 'bold');
    case '16to9slides'
        set(0, 'DefaultAxesLineWidth', 1.5, 'DefaultAxesFontName', 'Helvetica', 'DefaultAxesFontSize', 24, 'DefaultAxesFontWeight', 'bold');
    case 'fp_paper'
        set(0, 'DefaultAxesLineWidth', 1.5, 'DefaultAxesFontName', 'Helvetica', 'DefaultAxesFontSize', 8, 'DefaultAxesFontWeight', 'bold');
    case 'sfn_poster'
        set(0, 'DefaultAxesLineWidth', 2.0, 'DefaultAxesFontName', 'Helvetica', 'DefaultAxesFontSize', 24, 'DefaultAxesFontWeight', 'bold');
    case {'sfn_poster_2011', 'sfn_poster_2012', 'sfn_poster_2013'}
        set(0, 'DefaultAxesLineWidth', 2.0, 'DefaultAxesFontName', 'Helvetica', 'DefaultAxesFontSize', 18, 'DefaultAxesFontWeight', 'bold');
    case '20120519'
        set(0, 'DefaultAxesLineWidth', 2.0, 'DefaultAxesFontName', 'Helvetica', 'DefaultAxesFontSize', 12, 'DefaultAxesFontWeight', 'bold');
    case 'ms13_paper'
        set(0, 'DefaultAxesLineWidth', 1.5, 'DefaultAxesFontName', 'Helvetica', 'DefaultAxesFontSize', 8, 'DefaultAxesFontWeight', 'bold');
    case 'ms13_paper_unitdata'
        set(0, 'DefaultAxesLineWidth', 1.5, 'DefaultAxesFontName', 'Helvetica', 'DefaultAxesFontSize', 8, 'DefaultAxesFontWeight', 'bold');
    otherwise
        %set(0, 'DefaultAxesLineWidth', 4, 'DefaultAxesFontName', 'Helvetica', 'DefaultAxesFontSize', 24, 'DefaultAxesFontWeight', 'bold');
end

return
end
