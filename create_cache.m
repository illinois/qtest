function cache=create_cache(fname)
if ~exist('QtestCache','class')
    javaaddpath('.');
end
cache=javaObject('QtestCache',fname);
