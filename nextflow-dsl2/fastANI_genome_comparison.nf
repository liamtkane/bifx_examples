#!/usr/bin/env nextflow 

def helpMessage() {
    log.info"""
    ============================================================================
     :  Git version: ${version}
    ============================================================================
    Usage:

        Mandatory arguments:
            --tsv		TSV file with sample name, "Experimental" Assembly, and Ref Genome to compare
            --out_dir	Output Directory         
    """.stripIndent()
}            


nextflow.enable.dsl=2


params."out_dir" = 'out'


def proc_git = "git -C $baseDir rev-parse HEAD".execute()
version = proc_git.text.trim()

params.help = false
if (params.help){
    println(params)
    helpMessage()
    exit 0
}


process fastANI {

	container 'medicinalgenomics/fast-ani:latest'
	publishDir params."out_dir"

	tag {'fastANI' + '-' + sample_name}  

	input:
	tuple val(sample_name), path(query_assembly), path(ref_assembly)

	output:
	file("*fastANI.out")

	script:
	"""
	fastANI -q ${query_assembly} -r ${ref_assembly} -o ${sample_name}-fastANI.out
	"""
}


process fastANI_visualize {

	container 'medicinalgenomics/fast-ani:latest'
	publishDir params."out_dir"

	tag {'fastANI_visualize' + '-' + sample_name}  

	input:
	tuple val(sample_name), path(query_assembly), path(ref_assembly)

	output:
	file("*fastANI.out.visual")
	file("*fastANI.out.visual.pdf")

	script:
	"""
	fastANI -q ${query_assembly} -r ${ref_assembly} --visualize -o ${sample_name}-fastANI.out
	Rscript /opt/fastani/scripts/visualize.R ${query_assembly} ${ref_assembly} ${sample_name}-fastANI.out.visual
	"""

}


workflow {

	Channel
        .fromPath(params."tsv")
        .splitCsv(header: false, sep: '\t')
        .set {two_assembly_input}

    two_assembly_input
    	.view()    

    fastANI(two_assembly_input)	
	fastANI_visualize(two_assembly_input)
}