using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Sockets;
using System.Web;
using System.Web.Mvc;

namespace DeployingWebsites101Dojo.Extensions
{
    public static class HtmlHelperExtensions
    {
        public static string GetLocalIPAddress(this HtmlHelper helper)
        {
            string localIP;
            using (Socket socket = new Socket(AddressFamily.InterNetwork, SocketType.Dgram, 0))
            {
                socket.Connect("10.0.2.4", 65530);
                IPEndPoint endPoint = socket.LocalEndPoint as IPEndPoint;
                localIP = endPoint.Address.ToString();
            }

            return localIP;
        }

        public static string VersionInformation(this HtmlHelper helper)
        {
            var version = System.Reflection.Assembly.GetExecutingAssembly().GetName().Version;

            var versionString = string.Format("{0}", version.ToString(4));

            return versionString;
        }
    }
}