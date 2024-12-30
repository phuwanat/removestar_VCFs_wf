version 1.0

workflow removestar_VCFs {

    meta {
    author: "Phuwanat Sakornsakolpat"
        email: "phuwanat.sak@mahidol.edu"
        description: "removestar VCF"
    }

     input {
        File vcf_file
        File tabix_file
    }

    call run_removestaring { 
            input: vcf = vcf_file, tabix = tabix_file
    }

    output {
        File removestared_vcf = run_removestaring.out_file
        File removestared_tbi = run_removestaring.out_file_tbi
    }

}

task run_removestaring {
    input {
        File vcf
        File tabix
        Int memSizeGB = 4
        Int threadCount = 1
        Int diskSizeGB = 2*round(size(vcf, "GB")) + 20
    String out_name = basename(vcf, ".vcf.gz")
    }
    
    command <<<
    zcat ~{vcf} | awk -F'\t' '($3 != "*" && $4 != "*")' > ~{out_name}.removestared.vcf
    bgzip ~{out_name}.removestared.vcf
    tabix -p vcf ~{out_name}.removestared.vcf.gz
    >>>

    output {
        File out_file = select_first(glob("*.removestared.vcf.gz"))
        File out_file_tbi = select_first(glob("*.removestared.vcf.gz.tbi"))
    }

    runtime {
        memory: memSizeGB + " GB"
        cpu: threadCount
        disks: "local-disk " + diskSizeGB + " SSD"
        docker: "quay.io/biocontainers/bcftools@sha256:f3a74a67de12dc22094e299fbb3bcd172eb81cc6d3e25f4b13762e8f9a9e80aa"   # digest: quay.io/biocontainers/bcftools:1.16--hfe4b78e_1
        preemptible: 1
    }

}
