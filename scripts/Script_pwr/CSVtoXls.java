
import java.io.DataInputStream;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.ArrayList;
 
import org.apache.poi.hssf.usermodel.HSSFCell;
import org.apache.poi.hssf.usermodel.HSSFRow;
import org.apache.poi.hssf.usermodel.HSSFSheet;
import org.apache.poi.hssf.usermodel.HSSFWorkbook;
import org.apache.poi.ss.usermodel.Cell;

import java.io.BufferedReader;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.InputStreamReader;
import java.util.List;

 
 
public class CSVtoXls {
 
public static void main(String args[]) throws IOException
{
	
			String path=args[0];			
			//System.out.println(path);
			String[] files=new String[100];
			String strLine;
			try
			{			
				FileInputStream fstream = new FileInputStream(path+"/"+"Scenarios.txt");
				DataInputStream in = new DataInputStream(fstream);
				BufferedReader br = new BufferedReader(new InputStreamReader(in));
			 
				int no=0;
				while ((strLine = br.readLine()) != null)   {
				// Print the content on the console
				  files[no]=strLine;
			 	 no++;
				}
				String[] filenames=new String[no];
				for(int fno=0;fno<no;fno++)
				{
					 filenames[fno]=files[fno];
				}
			
	
for (int num=0;num<filenames.length;num++)
{
ArrayList arList=null;
ArrayList al=null;
String filename=filenames[num];
//System.out.println(filename);
String fName = path+"/"+filename+".csv";
String thisLine;
int count=0;
FileInputStream fis = new FileInputStream(fName);
DataInputStream myInput = new DataInputStream(fis);
int i=0;
arList = new ArrayList();
while ((thisLine = myInput.readLine()) != null)
{
al = new ArrayList();
String strar[] = thisLine.split(",");
for(int j=0;j<strar.length;j++)
{
al.add(strar[j]);
}
arList.add(al);
//System.out.println();
i++;
}
 
try
{
HSSFWorkbook hwb = new HSSFWorkbook();
HSSFSheet sheet = hwb.createSheet("new sheet");
for(int k=0;k<arList.size();k++)
{
ArrayList ardata = (ArrayList)arList.get(k);
HSSFRow row = sheet.createRow((short) 0+k);
for(int p=0;p<ardata.size();p++)
{
HSSFCell cell = row.createCell((short) p);
String data = ardata.get(p).toString();
if(data.startsWith("=")){
cell.setCellType(Cell.CELL_TYPE_STRING);
data=data.replaceAll("\"", "");
data=data.replaceAll("=", "");
cell.setCellValue(data);
}else if(data.startsWith("\"")){
data=data.replaceAll("\"", "");
cell.setCellType(Cell.CELL_TYPE_STRING);
cell.setCellValue(data);
}else{
data=data.replaceAll("\"", "");
cell.setCellType(Cell.CELL_TYPE_NUMERIC);
cell.setCellValue(data);
}
//*/
// cell.setCellValue(ardata.get(p).toString());
}
//System.out.println();
}
FileOutputStream fileOut = new FileOutputStream(path+"/"+filename+".xls");
hwb.write(fileOut);
fileOut.close();
System.out.println("Your excel file has been generated");
} catch ( Exception ex ) {
ex.printStackTrace();
} //main method ends
}
}catch(Exception e)
{
	System.out.println("Input file was not not found");
	//e.printStackTrace();
}
}
}
