# Copyright (c) 2023 [Ribose Inc](https://www.ribose.com).
# All rights reserved.
# This file is a part of metanorma
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
# TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
# PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR CONTRIBUTORS
# BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.

load("cirrus", "http", "json", "env")

def main():
    rsp = http.get("https://raw.githubusercontent.com/metanorma/metanorma-cli/main/.github/workflows/samples-smoke-matrix.json")
    matrix = json.loads(rsp.body())

    flavors = matrix["flavor"]
# cirrus-ci allows very limited resources for the free tier
# an attempt to execute all tests causes 2-4 hours ci run
# so we will just keep two flavors for testing
    flavors = flavors[:3]

    instances = {
        "darwin_arm64": {
            "macos_instance": {
                "image": "ghcr.io/cirruslabs/macos-monterey-xcode:latest"
            }
        },
        "linux_aarch64": {
            "arm_container": {
                "image": "ubuntu:20.04",
                "cpu": "3",
                "memory": "12G"
            }
        }
    }

    allow_failures = {
        "allow_failures": "true",
        "skip_notifications": "true"
    }
    only_if = "$CIRRUS_BRANCH == 'main' || $CIRRUS_PR != '' || $CIRRUS_TAG != ''"
    linux_install = {
        "install_script": "DEBIAN_FRONTEND=noninteractive apt-get -y update && " +
                          "DEBIAN_FRONTEND=noninteractive apt-get -y install wget unzip git default-jre"
    }
    macos_install = {
        "install_script": "brew update  && brew upgrade ca-certificates"
    }
    tasks = [ ]

    for host in [ "darwin_arm64", "linux_aarch64" ]:
        m_nm = "metanorma_" + host
        # cirrus-ci does not like '-' but metanorma makefile uses it
        m_bin = m_nm.replace("_", "-")
        m_zip = m_nm + ".zip"
        m_remote = "https://api.cirrus-ci.com/v1/artifact/build/$CIRRUS_BUILD_ID/" + m_zip
        for flavor in flavors:
            # Here we shall take care of private repos if they need to be handled
            # but it is not implemented due to resource limitation
            if (flavor["public"] and flavor["id"] != "ribose"):
                flow =  {
                    "name": "test_" + flavor["id"] + "_" + host,
                    "only_if": only_if,
                    "depends_on": [ host ],
                    "post_checkout_script": "rm Gemfile"
                }

                if host == "linux_aarch64":
                    flow.update(linux_install)
                else:
                    flow.update(macos_install)

                flow2 = {
                    "load_mentanorma_script": "wget -nv " + m_remote + " && unzip " + m_zip,
                    "relaton_cache": { "folder": ".relaton", "fingerprint_key": "relaton-" + host + "-" + flavor["id"] },
                    "fetch_sample_" + flavor["id"] + "_script": "git clone --depth 1 --recurse-submodules --shallow-submodules " +
                                                      "https://github.com/metanorma/mn-samples-" + flavor["id"] + ".git samples",
                    "chmod_script": "chmod a+x build/bin/" + m_bin,
                    "test_" + flavor["id"] + "_script": "build/bin/" + m_bin + " site generate samples " +
                                              "-c samples/metanorma.yml -o site-" + flavor["id"] + " --agree-to-terms",
                    "site_" + flavor["id"] + "_artifacts": { "path": "site-" + flavor["id"] + "/**" }
                }

                flow.update(flow2)
                flow.update(instances[host])

                if flavor["experimental"]:
                    flow.update(allow_failures)
                tasks.append (("task",  flow))

    return tasks
