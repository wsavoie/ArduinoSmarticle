using System;
using System.IO;
using System.Windows.Forms;
using NMotive;
using Microsoft.VisualBasic;
/// <summary>
/// Motive Batch Processor script for exporting a take file to FBX ASCII format.
/// </summary>
public class ExportCSV : ITakeProcessingScript
{
    /// <summary>
    /// The <c>ProcessTake</c> function is from the <c>ITakeProcessingScript</c> interface.
    /// Exports the given take to FBX ASCII format. The exported file is in the same 
    /// directory as the take file, and has the same name, but with a '.fbx' file 
    /// extension.
    /// </summary>
    /// <param name="t">The take to export.</param>
    /// <param name="progress">Progress indicator object. Not used in this
    /// function.</param>
    /// <returns>The result of the export process.</returns>
	// public string getFolder()
	// {
	// string v=Microsoft.VisualBasic.Interaction.InputBox("Folder","tell me folder to output to",
		// "A:\\2DSmartData\\crawl\\trials 9-21-17\\");
		// System.Windows.Forms.MessageBox.Show(v);
		// return v;
	// }
	public Result ProcessTake(Take t, ProgressIndicator progress)
	{	
		string v="A:\\2DSmartData\\crawl\\trials 9-21-17\\crawl 1.0 43on";
		
		// // using (var f = new System.Windows.Forms.OpenFileDialog())
		// // {
		// // if (f.ShowDialog() == DialogResult.OK) 
		// // {
		// // string v = f.SelectedPath;
		// // System.Windows.Forms.MessageBox.Show(v); 
		// // }
		// // }
		// if (dlg.ShowDialog() == DialogResult.OK ) 
		   // {
			  // // Do something here to handle data from dialog box.
		   // }
        // Construct an NMotive CSV exporter object with the desired
        // options. We will write CSV actors, marker nulls, and all skeletons.
        CSVExporter exporter = new CSVExporter
        {
			FrameRate=(float) t.FrameRate
        };
        // Construct the output FBX file. The output file will be co-located with the
        // take file and have the same name as the take file, but with an '.fbx' 
        // file extension.
		// exporter.DefaultFrameRate=120;
		string outputFileName = Path.GetFileNameWithoutExtension(t.FileName) + ".csv";
		string outputDirectory = Path.GetDirectoryName(t.FileName);
		string outputFile = Path.Combine(v, outputFileName);
		
        // Do the export and return the Export functions result object.
		return exporter.Export(t, outputFile, true);
	}
}
