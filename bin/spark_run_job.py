from __future__ import print_function
import subprocess
import sys
import os

NAMESPACE = 'spark-cluster'

# TODO@geo validate this
sparks_args = sys.argv[1]
# this can be
app_file_name = sys.argv[2]
app_args = sys.argv[3]

example_subfold = None
if app_file_name.endswith('.py'):
    example_subfold = 'python'
else:
    example_subfold = 'java'

example_file_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), '../spark/benchmark', example_subfold,
                                 app_file_name)
spark_example_file_path = '/tmp/%s' % app_file_name


def run_cmd(cmd, debug=True):
    if debug:
        print("Running cmd: %s" % cmd)
        sys.stdout.flush()

    process = subprocess.Popen(cmd, stdout=subprocess.PIPE, shell=True)
    out, err = process.communicate()

    if err:
        print("ERROR: ", err)
    else:
        print("OK")

    return out.strip()


zepplin_controller = run_cmd(
    "kubectl get pods --namespace=%s | grep zeppelin-controller | awk '{print $1}'" % (NAMESPACE,))

# copy example file that we want to run on the machine
copy_spark_file_cmd = "kubectl exec -i {0} --namespace={1} -- /bin/bash -c 'cat > {2}' < {3}".format(
    zepplin_controller, NAMESPACE, spark_example_file_path, example_file_path)

run_spark_job = "kubectl exec -i {0} --namespace={1} -ti -- spark-submit --master=spark://spark-master:7077 {2} {3} {4}".format(
    zepplin_controller, NAMESPACE, sparks_args, spark_example_file_path, app_args)

if __name__ == '__main__':
    run_cmd(copy_spark_file_cmd)
    print(run_cmd(run_spark_job))
