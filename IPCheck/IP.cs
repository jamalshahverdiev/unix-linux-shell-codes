using System;
using System.Collections.Generic;
using System.Text;

namespace IPCheck
{
    public class IP : IComparable
    {
        public IP(string line)
        {
            string[] values = line.Split(' ');
            Address = values[0];
            Status = values[1];
            string[] ips = Address.Split('.');
            P1 = Convert.ToInt32(ips[0]);
            P2 = Convert.ToInt32(ips[1]);
            P3 = Convert.ToInt32(ips[2]);
            P4 = Convert.ToInt32(ips[3]);
        }

        int P1 { get; set; }

        int P2 { get; set; }

        int P3 { get; set; }

        int P4 { get; set; }

        public string Address { get; set; }

        public string Status { get; set; }

        public int CompareTo(object obj)
        {
            IP comp = (IP)obj;
            int result = P1.CompareTo(comp.P1);
            if (result != 0) return result;
            result = P2.CompareTo(comp.P2);
            if (result != 0) return result;
            result = P3.CompareTo(comp.P3);
            if (result != 0) return result;
            result = P4.CompareTo(comp.P4);
            return result;
        }
    }
}