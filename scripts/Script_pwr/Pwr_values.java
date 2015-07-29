import java.io.File;
import jxl.Cell;
import jxl.Sheet;
import jxl.Workbook;
import jxl.write.Label;
import jxl.write.Number;
import jxl.write.WritableSheet;
import jxl.write.WritableWorkbook;

import java.io.BufferedReader;
import java.io.DataInputStream;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.List;


public class Pwr_values {

		
		public static void main(String[] args) {

			String target=args[0];
			String path=args[1];
			
			System.out.println("target is"+target);
			String[] files=new String[100];
			String strLine;
			try
			{			
				FileInputStream fstream = new FileInputStream(path+"/"+"Scenarios.txt");
				DataInputStream in = new DataInputStream(fstream);
				BufferedReader br = new BufferedReader(new InputStreamReader(in));
			 
				int num=0;
				while ((strLine = br.readLine()) != null)   {
				 files[num]=strLine;
			 	 num++;
				}
				String[] sheetnames=new String[num];
				for(int fno=0;fno<num;fno++)
				{
					 sheetnames[fno]=files[fno];
				}
			
			
			try
			{
				for(int k=0;k<sheetnames.length;k++)
				{
					Workbook workbook = Workbook.getWorkbook(new File(path+"/"+target));
					WritableWorkbook copy = Workbook.createWorkbook(new File(path+"/"+target), workbook);
					WritableSheet sheet2 = copy.getSheet(k+1);
					WritableSheet sheet3 = copy.getSheet(k);
					
					for(int n=0;n<sheetnames.length;n++)
					{
                    				Label label1 = new Label(1,2+n,sheetnames[n]);
						sheet3.addCell(label1);

					}				
					try
					{
						Workbook workbook1 = Workbook.getWorkbook(new File(path+"/"+sheetnames[k]+".xls"));
						Sheet sheet = workbook1.getSheet(0);
					
						int rows=sheet.getRows();
						int cols=sheet.getColumns();
						System.out.println("rows are"+rows+"\ncols are"+cols);
						for(int i=0;i<cols;i++)
						{

							for(int j=0;j<rows;j++)
							{	

								Cell cell1 = sheet.getCell(i, j);
								String str=cell1.getContents();
								//System.out.println(str);
						
								String pattern=".*[a-zA-Z].*";
								if(str.matches(pattern)||str.isEmpty())
								{
									if(target.equals("IW.xls"))
									{									
										Label label = new Label(i+1, j+24, str);
										sheet2.addCell(label);
									}
									else
									{
										Label label = new Label(i, j+24, str);
										sheet2.addCell(label);									

									}
								}
								else
								{

									if(target.equals("IW.xls"))
									{
										Double l=Double.parseDouble(str);
										//System.out.println(l);
							
										Number label = new Number(i+1, j+24, l);
										sheet2.addCell(label);
									}

									else
									{
										Double l=Double.parseDouble(str);
										//System.out.println(l);
							
										Number label = new Number(i, j+24, l);
										sheet2.addCell(label);
										
									}
								}
						
								//break;
							}
							//break;
						}
						workbook1.close();
						System.out.println(sheetnames[k]+".xls file copied successfully");
						//break;
					}
					catch(Exception e)
					{
						//copy.write();
						//copy.close();
						System.out.println(sheetnames[k]+".xls Inputfile was not found or corrupted");
						//e.printStackTrace();
					}
					copy.write();
					copy.close();
				}
				
				
			}catch(Exception e)
			{
				System.out.println("Target File was not found or corrupted");
				//e.printStackTrace();
			}
			}catch(Exception e)
			{
				System.out.println("File not found or corrupted");
				//e.printStackTrace();
			}
			
		 
		}

}

