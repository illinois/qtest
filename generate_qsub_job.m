function generate_qsub_job(job_name,worker_ids,walltime)
%note: change MCR_loc to the MCR installation folder
MCR_loc='/usr/users/5/gymaple/MCR';

if mod(length(worker_ids),16)~=0
    error('Workers not multiple of 16!');
end
if length(unique(worker_ids))~=length(worker_ids)
    error('Duplicate worker id found!');
end
fid=fopen([job_name,'.job'],'w');
fprintf(fid,'#!/bin/bash\n');
fprintf(fid,'#PBS -l ncpus=%d\n',length(worker_ids));
fprintf(fid,'#PBS -l walltime=%s\n',walltime);
fprintf(fid,'#PBS -j oe\n');
fprintf(fid,'#PBS -q batch\n');
fprintf(fid,'cd $HOME\n');
fprintf(fid,'export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:%s/v717/runtime/glnxa64:%s/v717/bin/glnxa64:%s/v717/sys/os/glnxa64:%s/v717/sys/java/jre/glnxa64/jre/lib/amd64/native_threads:%s/v717/sys/java/jre/glnxa64/jre/lib/amd64/server:%s/v717/sys/java/jre/glnxa64/jre/lib/amd64\n', ...
    MCR_loc,MCR_loc,MCR_loc,MCR_loc,MCR_loc,MCR_loc);
fprintf(fid,'export XAPPLRESDIR=%s/v717/X11/app-defaults\n',MCR_loc);
for i=1:length(worker_ids)
   fprintf(fid,'dplace -c %d ./qtest_worker %s %d &\n',i-1,job_name,worker_ids(i)); 
end
fprintf(fid,'wait\n');
fclose(fid);
