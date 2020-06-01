using System;
using System.IO;
using System.Collections.Generic;
using System.Text;
using System.Timers;

namespace IPCheck
{
    class Program
    {
        static void Main(string[] args)
        {
            var watch = System.Diagnostics.Stopwatch.StartNew();
            var ipValues = File.ReadAllLines(@"C:\CV\source.txt");
            List<IP> IPs = new List<IP>();
            foreach(string value in ipValues)
            {
                IPs.Add(new IP(value));
            }

            IPs.Sort();
            StringBuilder builder = new StringBuilder();
            int open = 0;
            int closed = 0;
            IP last = IPs[0];

            for (int i = 1;i< IPs.Count; i++)
            {
                
                if(last.Address != IPs[i].Address)
                {
                    builder.AppendLine($"{last.Address} open:{open} closed:{closed}");
                    last = IPs[i];
                    open = 0;
                    closed = 0;
                }

                if(IPs[i].Status[0] == 'o')
                {
                    open++;
                }
                else
                {
                    closed++;
                }
            }

            File.WriteAllText(@"C:\CV\results.txt", builder.ToString());
            watch.Stop();
            
            Console.WriteLine(watch.Elapsed);
            Console.ReadLine();
        }
    }
}